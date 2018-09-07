<?php
// src/AppBundle/Controller/eFaInitController.php
namespace AppBundle\Controller;

use AppBundle\Entity\eFaInitTask;
use AppBundle\Entity\passwordCompareTask;
use AppBundle\Form\LanguageTaskType;
use AppBundle\Form\LanguageEditTaskType;
use AppBundle\Form\YesNoTaskType;
use AppBundle\Form\YesNoEditTaskType;
use AppBundle\Form\TextboxTaskType;
use AppBundle\Form\TextboxEditTaskType;
use AppBundle\Form\PasswordTaskType;
use AppBundle\Form\PasswordEditTaskType;
use AppBundle\Form\TimezoneTaskType;
use AppBundle\Form\TimezoneEditTaskType;
use AppBundle\Form\VerifySettingsTaskType;
use AppBundle\Form\InterfaceTaskType;
use AppBundle\Form\InterfaceEditTaskType;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Component\HttpFoundation\Session\SessionInterface;
use Symfony\Component\Process\Process;
use Symfony\Component\Process\Exception\ProcessFailedException;
use Symfony\Component\Validator\Validation;

class eFaInitController extends Controller
{
    protected $timeout=900;

    /**
     * @Route("/{_locale}",
     *     name="languagepage",
     *     defaults={"edit"=null}
     * )
     * @Route("/{_locale}/{edit}",
     *     name="languageeditpage",
     *     requirements={"edit"="edit"}
     * )
     */
    public function indexAction(Request $request, $edit, SessionInterface $session)
    {
        $task = new eFaInitTask();

        if ($edit === "edit") { 
            $form = $this->createForm(LanguageEditTaskType::class, $task, array('locale' => $request->getLocale()));
        } else {
            $form = $this->createForm(LanguageTaskType::class, $task, array('locale' => $request->getLocale()));
        }

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $task = $form->getData();

            $session->set('locale', $task->getLanguage()); 

            if ($edit === "edit") {
                return $this->redirectToRoute('verifysettingspage', array('_locale' => $task->getLanguage(), 'slug' => 'verify'));
            } else {
                return $this->redirectToRoute('textboxpage', array('_locale' => $task->getLanguage(), 'slug' => 'hostname'));
            }
        }
        if ($edit === "edit") {
            return $this->render('languageedit/index.html.twig', array(
                'form' => $form->createView(),
            ));
        } else { 
            return $this->render('language/index.html.twig', array(
                'form' => $form->createView(),
            ));
        }
    }

    /**
     * @Route("/")
     */
    public function localeAction(Request $request) 
    {
        $clientLocale = strtolower(str_split($_SERVER['HTTP_ACCEPT_LANGUAGE'], 2)[0]);
        switch ($clientLocale) {
        case 'fr':
            return $this->redirectToRoute('languagepage', array('_locale' => 'fr'));
        break;
        case 'da':
            return $this->redirectToRoute('languagepage', array('_locale' => 'da'));
        break;
        case 'de':
            return $this->redirectToRoute('languagepage', array('_locale' => 'de'));
        break;
        case 'nl':
            return $this->redirectToRoute('languagepage', array('_locale' => 'nl'));
        break;
        case 'zh_CN':
            return $this->redirectToRoute('languagepage', array('_locale' => 'zh_CN'));
        break;
        case 'zh_TW':
            return $this->redirectToRoute('languagepage', array('_locale' => 'zh_TW'));
        break;
        case 'pt_PT':
            return $this->redirectToRoute('languagepage', array('_locale' => 'pt_PT'));
        break;
        case 'tr':
            return $this->redirectToRoute('languagepage', array('_locale' => 'tr'));
        break;
        case 'sv':
            return $this->redirectToRoute('languagepage', array('_locale' => 'sv'));
        break;
        case 'ru':
            return $this->redirectToRoute('languagepage', array('_locale' => 'ru'));
        break;
        default:
            return $this->redirectToRoute('languagepage', array('_locale' => 'en'));
        break;
        }
    }

    /**
     * @Route("/{_locale}/{slug}",
     *     name="textboxpage",
     *     requirements={"slug"="hostname|domainname|email|ipv4address|ipv4netmask|ipv4gateway|ipv6address|ipv6prefix|ipv6gateway|dns1|dns2|webusername|cliusername|mailserver|ianacode|orgname"},
     *     defaults={"_locale": "en", "edit" = null}
     * )
     * @Route("/{_locale}/{slug}/{edit}",
     *     name="textboxeditpage",
     *     requirements={"slug"="hostname|domainname|email|ipv4address|ipv4netmask|ipv4gateway|ipv6address|ipv6prefix|ipv6gateway|dns1|dns2|webusername|cliusername|mailserver|ianacode|orgname", "edit"="edit"},
     *     defaults={"_locale": "en"}
     * )
     */
    public function textboxAction(Request $request, $edit, $slug, SessionInterface $session)
    {
        $task = new eFaInitTask();

        switch ($slug) 
        {
            case "hostname":
                $options = array(
                    'varLabel'    => 'Please enter a hostname',
                    'varProperty' => 'Hostname',
                    'varData'     => $session->get($slug),
                );
                $varTitle     = 'Hostname';
                $nextSlug     = 'domainname';
                $nextPage     = 'textboxpage';
                $previousSlug = 'language';
                $previousPage = 'languagepage';
            break;
            case "domainname":
                $options = array(
                    'varLabel'    => 'Please enter a domain name',
                    'varProperty' => 'Domainname',
                    'varData'     => $session->get($slug),
                );
                $varTitle     = 'Domain Name';
                $nextSlug     = 'email';
                $nextPage     = 'textboxpage';
                $previousSlug = 'hostname';
                $previousPage = 'textboxpage';
            break;
            case "email":
                $options = array(
                    'varLabel'    => 'Please enter an email address for important notifications',
                    'varProperty' => 'Email',
                    'varData'     => $session->get($slug),
                );
                $varTitle     = 'Email';
                $nextSlug     = 'interface';
                $nextPage     = 'interfacepage';
                $previousSlug = 'domainname';
                $previousPage = 'textboxpage';
            break;
            case "ipv4address":
                $options = array(
                    'varLabel'    => 'Please enter a valid IPv4 address',
                    'varProperty' => 'IPv4address',
                    'varData'     => $session->get($slug),
                );
                if ($options['varData'] === '' || $options['varData'] === null) {
                    try {
                        $interface = $session->get('interface');
                        $process = new Process("ifconfig $interface | grep inet\ | awk '{print $2}'");
                        $process->mustRun();
                        $options['varData'] = $process->getOutput();
                    } catch (ProcessFailedException $exception) {
                        $options['varData'] = '';
                    } 
                }
                $varTitle     = 'IPv4 Address';
                $nextSlug     = 'ipv4netmask';
                $nextPage     = 'textboxpage';
                $previousSlug = 'configipv4';
                $previousPage = 'yesnopage';
            break;
            case "ipv4netmask":
                $options = array(
                    'varLabel'    => 'Please enter a valid IPv4 netmask',
                    'varProperty' => 'IPv4netmask',
                    'varData'     => $session->get($slug),
                );

                if ($options['varData'] === '' || $options['varData'] === null) {
                    try {
                        $interface = $session->get('interface');
                        $process = new Process("ifconfig $interface | grep inet\ | awk '{print $4}'");
                        $process->mustRun();
                        $options['varData'] = $process->getOutput();
                    } catch (ProcessFailedException $exception) {
                        $options['varData'] = '';
                    } 
                }

                $varTitle     = 'IPv4 Netmask';
                $nextSlug     = 'ipv4gateway';
                $nextPage     = 'textboxpage';
                $previousSlug = 'ipv4address';
                $previousPage = 'textboxpage';
            break;
            case "ipv4gateway":
                $options = array(
                    'varLabel'    => 'Please enter a valid IPv4 gateway',
                    'varProperty' => 'IPv4gateway',
                    'varData'     => $session->get($slug),
                );

                if ($options['varData'] === '' || $options['varData'] === null) {
                    try {
                        $process = new Process("route -n | grep 0.0.0.0 | awk '{print $2}' | grep -v 0.0.0.0");
                        $process->mustRun();
                        $options['varData'] = $process->getOutput();
                    } catch (ProcessFailedException $exception) {
                        $options['varData'] = '';
                    } 
                }

                $varTitle     = 'IPv4 Gateway';
                $nextSlug     = 'configipv6';
                $nextPage     = 'yesnopage';
                $previousSlug = 'ipv4netmask';
                $previousPage = 'textboxpage';
            break;
             case "ipv6address":
                $options = array(
                    'varLabel'    => 'Please enter a valid IPv6 address',
                    'varProperty' => 'IPv6address',
                    'varData'     => $session->get($slug),
                );

                if ($options['varData'] === '' || $options['varData'] === null) {
                    try {
                        $interface = $session->get('interface');
                        $process = new Process("ifconfig $interface | grep inet6\ | grep global | awk '{print $2}'");
                        $process->mustRun();
                        $options['varData'] = $process->getOutput();
                    } catch (ProcessFailedException $exception) {
                        $options['varData'] = '';
                    } 
                }

                $varTitle     = 'IPv6 Address';
                $nextSlug     = 'ipv6prefix';
                $nextPage     = 'textboxpage';
                $previousSlug = 'configipv6';
                $previousPage = 'yesnopage';
            break;
            case "ipv6prefix":
                $options = array(
                    'varLabel'    => 'Please enter a valid IPv6 prefix',
                    'varProperty' => 'IPv6prefix',
                    'varData'     => $session->get($slug),
                );

                if ($options['varData'] === '' || $options['varData'] === null) {
                    try {
                        $interface = $session->get('interface');
                        $process = new Process("ip add show $interface | grep inet6\ | grep global | awk '{print $2}' | awk -F'/' '{print $2}'");
                        $process->mustRun();
                        $options['varData'] = $process->getOutput();
                    } catch (ProcessFailedException $exception) {
                        $options['varData'] = '';
                    } 
                }

                $varTitle     = 'IPv6 Prefix';
                $nextSlug     = 'ipv6gateway';
                $nextPage     = 'textboxpage';
                $previousSlug = 'ipv6address';
                $previousPage = 'textboxpage';
            break;
            case "ipv6gateway":
                $options = array(
                    'varLabel'    => 'Please enter a valid IPv6 gateway',
                    'varProperty' => 'IPv6gateway',
                    'varData'     => $session->get($slug),
                );

                if ($options['varData'] === '' || $options['varData'] === null) {
                    try {
                        $process = new Process("route -n -6 | grep UG | grep ::/0 | awk '{print $2}'");
                        $process->mustRun();
                        $options['varData'] = $process->getOutput();
                    } catch (ProcessFailedException $exception) {
                        $options['varData'] = '';
                    } 
                }

                $varTitle     = 'IPv6 Gateway';
                $nextSlug     = 'configrecursion';
                $nextPage     = 'yesnopage';
                $previousSlug = 'ipv6prefix';
                $previousPage = 'textboxpage';
            break;
            case "dns1":
                $options = array(
                    'varLabel'    => 'Please enter the primary DNS address',
                    'varProperty' => 'DNS1',
                    'varData'     => $session->get($slug),
                );

                if ($options['varData'] === '' || $options['varData'] === null) {
                    try {
                        $process = new Process("grep nameserver /etc/resolv.conf | awk '{print $2}' | sed -n 1p");
                        $process->mustRun();
                        $options['varData'] = $process->getOutput();
                    } catch (ProcessFailedException $exception) {
                        $options['varData'] = '';
                    } 
                }

                $varTitle     = 'Primary DNS';
                $nextSlug     = 'dns2';
                $nextPage     = 'textboxpage';
                $previousSlug = 'configrecursion';
                $previousPage = 'yesnopage';
            break;
            case "dns2":
                $options = array(
                    'varLabel'    => 'Please enter the secondary DNS address',
                    'varProperty' => 'DNS2',
                    'varData'     => $session->get($slug),
                );

                if ($options['varData'] === '' || $options['varData'] === null) {
                    try {
                        $process = new Process("grep nameserver /etc/resolv.conf | awk '{print $2}' | sed -n 2p");
                        $process->mustRun();
                        $options['varData'] = $process->getOutput();
                    } catch (ProcessFailedException $exception) {
                        $options['varData'] = '';
                    } 
                }

                $varTitle     = 'Secondary DNS';
                $nextSlug     = 'webusername';
                $nextPage     = 'textboxpage';
                $previousSlug = 'dns1';
                $previousPage = 'textboxpage';
            break;
            case "webusername":
                $options = array(
                    'varLabel'    => 'Please enter the username for the admin web interface',
                    'varProperty' => 'Webusername',
                    'varData'     => $session->get($slug),
                );
                $varTitle     = 'Web Admin Username';
                $nextSlug     = 'webpassword';
                $nextPage     = 'passwordpage';
                $previousSlug = 'configrecursion';
                $previousPage = 'yesnopage';
            break;
            case "cliusername":
                $options = array(
                    'varLabel'    => 'Please enter the username for the admin console interface',
                    'varProperty' => 'CLIusername',
                    'varData'     => $session->get($slug),
                );
                $varTitle     = 'Console Admin Username';
                $nextSlug     = 'clipassword';
                $nextPage     = 'passwordpage';
                $previousSlug = 'webpassword';
                $previousPage = 'passwordpage';
            break;
            case "mailserver":
                $options = array(
                    'varLabel'    => 'Please enter the IP or hostname of the local mail server',
                    'varProperty' => 'Mailserver',
                    'varData'     => $session->get($slug),
                );
                $varTitle     = 'Local Mail Server';
                $nextSlug     = 'ianacode';
                $nextPage     = 'textboxpage';
                $previousSlug = 'timezone';
                $previousPage = 'timezonepage';
            break;
            case "ianacode":
                $options = array(
                    'varLabel'    => 'Please enter your IANA country code',
                    'varProperty' => 'IANAcode',
                    'varData'     => $session->get($slug),
                );
                $varTitle     = 'IANA Code';
                $nextSlug     = 'orgname';
                $nextPage     = 'textboxpage';
                $previousSlug = 'mailserver';
                $previousPage = 'textboxpage';
            break;
            case "orgname":
                $options = array(
                    'varLabel'    => 'Please enter your organization name (No spaces, dots, or underscores)',
                    'varProperty' => 'Orgname',
                    'varData'     => $session->get($slug),
                );
                $varTitle     = 'Organization Name';
                $nextSlug     = 'verify';
                $nextPage     = 'verifysettingspage';
                $previousSlug = 'ianacode';
                $previousPage = 'textboxpage';
            break;

        }

        if ($edit === 'edit') {
            $form = $this->createForm(TextboxEditTaskType::class, $task, $options);
        } else { 
            $form = $this->createForm(TextboxTaskType::class, $task, $options);
        }

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $task = $form->getData();

            $getMethod = "get" . $slug;
            $session->set($slug, $task->$getMethod());
            if ($edit === 'edit') {
                $action = 'verify';
                $page   = 'verifysettingspage';
            } else {
                $action = $form->get('Next')->isClicked() || $form->get('NextHidden')->isClicked() ? $nextSlug : $previousSlug;
                $page   = $form->get('Next')->isClicked() || $form->get('NextHidden')->isClicked() ? $nextPage : $previousPage;
            }

            return $this->redirectToRoute($page, array('_locale' => $request->getLocale(), 'slug' => $action));
        }
        
        if ($edit === 'edit') {
            return $this->render('textboxedit/index.html.twig', array(
                'form' => $form->createView(),
                'title' => $varTitle
            ));
        } else {
            return $this->render('textbox/index.html.twig', array(
                'form' => $form->createView(),
                'title' => $varTitle
            ));
        }
    }


    /**
     * @Route("/{_locale}/{slug}",
     *     name="interfacepage",
     *     requirements={"slug"="interface"},
     *     defaults={"_locale": "en", "edit" = null}
     * )
     * @Route("/{_locale}/{slug}/{edit}",
     *     name="interfaceeditpage",
     *     requirements={"slug"="interface", "edit"="edit"},
     *     defaults={"_locale": "en"}
     * )
     */
    public function interfaceAction(Request $request, $edit, $slug, SessionInterface $session)
    {
        $task = new eFaInitTask();

        $options = array(
            'varProperty' => 'Interface',
        );
        $varLabel     = 'Please choose your interface';
        $nextSlug     = 'configipv4';
        $nextPage     = 'yesnopage';
        $previousSlug = 'email';
        $previousPage = 'textboxpage';
        try {
            $process = new Process("ip link show | grep ^[0-9] | awk -F': ' '{print $2}' | sed -e '/^lo/d' | sort | uniq");
            $process->mustRun();
            foreach ( explode('\n',$process->getOutput()) as $var ) 
            {
               $options['varChoices'][trim($var)] = trim($var);
            }
        } catch (ProcessFailedException $exception) {
               $options['varChoices']['eth0'] = 'eth0';
        }
        if ($edit === 'edit') {
            $form = $this->createForm(InterfaceEditTaskType::class, $task, $options);
        } else {
            $form = $this->createForm(InterfaceTaskType::class, $task, $options);
        }

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $task = $form->getData();

            $session->set('interface', $task->getInterface()); 

            if ($edit === 'edit') {
                $action = 'verify';
                $page   = 'verifysettingspage';
            } else {
                $action = $form->get('Next')->isClicked() || $form->get('NextHidden')->isClicked() ? $nextSlug : $previousSlug;
                $page   = $form->get('Next')->isClicked() || $form->get('NextHidden')->isClicked() ? $nextPage : $previousPage;
            }
            
            return $this->redirectToRoute($page, array('_locale' => $request->getLocale(), 'slug' => $action));

       }
        if ($edit === "edit") {
            return $this->render('interfaceedit/index.html.twig', array(
                'form' => $form->createView(),
                'label' => $varLabel,
            ));
        } else { 
            return $this->render('interface/index.html.twig', array(
                'form' => $form->createView(),
                'label' => $varLabel,
            ));
        }
    }


    /**
     * @Route("/{_locale}/{slug}",
     *     name="yesnopage",
     *     requirements={"slug"="configipv4|configipv6|configrecursion|configvirtual|configutc"},
     *     defaults={"_locale": "en", "edit" = null}
     * )
     * @Route("/{_locale}/{slug}/{edit}",
     *     name="yesnoeditpage",
     *     requirements={"slug"="configipv4|configipv6|configrecursion|configvirtual|configutc","edit"="edit"},
     *     defaults={"_locale": "en"}
     * )
     */
    public function yesnoAction(Request $request, $slug, $edit, SessionInterface $session)
    {
        if ($edit === 'edit') {
            $form = $this->createForm(YesNoEditTaskType::class);
        } else {
            $form = $this->createForm(YesNoTaskType::class);
        }

        switch($slug) 
        {
            case "configipv4":
                $varTitle     = 'Configure IPv4';
                $varQuestion  = 'Do you want to set a static IPv4 address?';
                $yesSlug      = 'ipv4address';
                $yesPage      = 'textboxpage';
                $noSlug       = 'configipv6';
                $noPage       = 'yesnopage';
                $previousPage = 'interfacepage';
                $previousSlug = 'interface';
            break;
            case "configipv6":
                $varTitle     = 'Configure IPv6';
                $varQuestion  = 'Do you want to set a static IPv6 address?';
                $yesSlug      = 'ipv6address';
                $yesPage      = 'textboxpage';
                $noSlug       = 'configrecursion';
                $noPage       = 'yesnopage';
                $previousPage = 'yesnopage';
                $previousSlug = 'configipv4';
            break;
            case "configrecursion":
                $varTitle     = 'Configure DNS Recursion';
                $varQuestion  = 'Do you want to enable full DNS Recursion?';
                $yesSlug      = 'webusername';
                $yesPage      = 'textboxpage';
                $noSlug       = 'dns1';
                $noPage       = 'textboxpage';
                $previousPage = 'yesnopage';
                $previousSlug = 'configipv6';
            break;
            case "configvirtual":
                $varTitle     = 'Configure Hypervisor Tools';
                $varQuestion  = 'Do you want to install hypervisor tools for your hypervisor?';
                $yesSlug      = 'configutc';
                $yesPage      = 'yesnopage';
                $noSlug       = 'configutc';
                $noPage       = 'yesnopage';
                $previousPage = 'passwordpage';
                $previousSlug = 'clipassword';
            break;
            case "configutc":
                $varTitle     = 'Configure UTC Time';
                $varQuestion  = 'Is the host set to UTC time?';
                $yesSlug      = 'timezone';
                $yesPage      = 'timezonepage';
                $noSlug       = 'timezone';
                $noPage       = 'timezonepage';
                $previousPage = 'yesnopage';
                $previousSlug = 'configvirtual';
            break;
        }

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            if ($edit === 'edit') {
                if ($form->get('Return')->isClicked()) {
                    $action = 'verifysettingspage';
                    $slug   = 'verify';
                } elseif ($form->get('Yes')->isClicked()) {
                    $session->set($slug, '1');
                    $action = 'verifysettingspage';
                    $slug   = 'verify';
                } else {
                   $session->set($slug, '0');
                   $action = 'verifysettingspage';
                   $slug   = 'verify';
                }
           } else {
                if ($form->get('Back')->isClicked()) {
                    $action = $previousPage;
                   $slug   = $previousSlug;
                } elseif ($form->get('Yes')->isClicked()) {
                    $session->set($slug, '1');
                    $action = $yesPage;
                    $slug   = $yesSlug;
                } else {
                   $session->set($slug, '0');
                   $action = $noPage;
                   $slug   = $noSlug;
                }
           }

            return $this->redirectToRoute($action, array('_locale' => $request->getLocale(), 'slug' => $slug));
        }
        if ($edit === 'edit') {
            return $this->render('yesnoedit/index.html.twig', array(
                'form' => $form->createView(),
                'title' => $varTitle,
                'question' => $varQuestion
                ));
        } else {
            return $this->render('yesno/index.html.twig', array(
                'form' => $form->createView(),
                'title' => $varTitle,
                'question' => $varQuestion
                ));
        }
    }

    /**
     * @Route("/{_locale}/{slug}",
     *     name="passwordpage",
     *     requirements={"slug"="webpassword|clipassword"},
     *     defaults={"_locale": "en", "edit" = null}
     * )
     * @Route("/{_locale}/{slug}/{edit}",
     *     name="passwordeditpage",
     *     requirements={"slug"="webpassword|clipassword", "edit" = "edit"},
     *     defaults={"_locale": "en"}
     * )
     */
    public function passwordAction(Request $request, $slug, $edit, SessionInterface $session)
    {
        $task = new eFaInitTask();

        switch ($slug) 
        {
            case "webpassword":
                $options = array(
                    'varLabel1'    => 'Please enter the web admin password',
                    'varLabel2'    => 'Please re-enter the web admin password',
                    'varProperty1' => 'Webpassword1',
                    'varProperty2' => 'Webpassword2',
                );
                $varTitle     = 'Web Admin Password';
                $nextSlug     = 'cliusername';
                $nextPage     = 'textboxpage';
                $previousSlug = 'webusername';
                $previousPage = 'textboxpage';
            break;
            case "clipassword":
                $options = array(
                    'varLabel1'    => 'Please enter the console admin password',
                    'varLabel2'    => 'Please re-enter the console admin password',
                    'varProperty1' => 'CLIpassword1',
                    'varProperty2' => 'CLIpassword2',
                );
                $varTitle     = 'Console Admin Password';
                $nextSlug     = 'configvirtual';
                $nextPage     = 'yesnopage';
                $previousSlug = 'cliusername';
                $previousPage = 'textboxpage';
            break;

        }
        if ($edit === 'edit') {
             $form = $this->createForm(PasswordEditTaskType::class, $task, $options);
        } else {
             $form = $this->createForm(PasswordTaskType::class, $task, $options);
        }

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $task = $form->getData();

            $getMethod = "get" . $options['varProperty1'];
            $session->set($slug, $task->$getMethod());
            
            $passwordcompare = new passwordCompareTask();
            $passwordcompare->setPassword1($session->get('webpassword'));
            $passwordcompare->setPassword2($session->get('clipassword'));
            
            //$validator = Validation::createValidator();
            $validator = $this->get('validator');
            $errors = $validator->validate($passwordcompare);

            if (count($errors) === 0) {
                if ($edit === 'edit') {
                    $action = 'verify';
                   $page   = 'verifysettingspage';
                } else {
                    $action = $form->get('Next')->isClicked() || $form->get('NextHidden')->isClicked() ? $nextSlug : $previousSlug;
                    $page   = $form->get('Next')->isClicked() || $form->get('NextHidden')->isClicked() ? $nextPage : $previousPage;
                }

                return $this->redirectToRoute($page, array('_locale' => $request->getLocale(), 'slug' => $action));
            } else {
                if ($edit === 'edit') {
                    return $this->render('passwordeditbox/index.html.twig', array(
                        'form' => $form->createView(),
                        'error' => 'Web and ClI Passwords cannot match',
                        'title' => $varTitle,
                    ));
                } else {
                    return $this->render('passwordbox/index.html.twig', array(
                        'form' => $form->createView(),
                        'error' => 'Web and CLI Passwords cannot match',
                        'title' => $varTitle,
                    ));
                }
            }
        }
        
        if ($edit === 'edit') {
            return $this->render('passwordeditbox/index.html.twig', array(
                'form' => $form->createView(),
                'error' => null,
                'title' => $varTitle,
            ));
        } else {
            return $this->render('passwordbox/index.html.twig', array(
                'form' => $form->createView(),
                'error' => null,
                'title' => $varTitle,
            ));
        }
    }

    /**
     * @Route("/{_locale}/{slug}",
     *     name="timezonepage",
     *     requirements={"slug"="timezone"},
     *     defaults={"_locale": "en", "edit" = null}
     * )
      * @Route("/{_locale}/{slug}/{edit}",
     *     name="timezoneeditpage",
     *     requirements={"slug"="timezone", "edit" = "edit"},
     *     defaults={"_locale": "en"}
     * )
     */
    public function timezoneAction(Request $request, $slug, $edit, SessionInterface $session)
    {
        $task = new eFaInitTask();

        $varData = $session->get($slug);
        
        if ($edit === 'edit') {
            $form = $this->createForm(TimezoneEditTaskType::class, $task, array('varData' => $varData));
        } else { 
            $form = $this->createForm(TimezoneTaskType::class, $task, array('varData' => $varData));
        }
    
        $form->handleRequest($request);
    
        if ($form->isSubmitted() && $form->isValid()) {
            $task = $form->getData();

            $session->set('timezone', $task->getTimezone()); 
            
            if ($edit === 'edit') {
                $action = 'verify';
                $page   = 'verifysettingspage';
            } else {
                $action = $form->get('Next')->isClicked() || $form->get('NextHidden')->isClicked() ? 'mailserver' : 'configutc';
                $page   = $form->get('Next')->isClicked() || $form->get('NextHidden')->isClicked() ? 'textboxpage' : 'yesnopage';
            }

            return $this->redirectToRoute($page, array('_locale' => $request->getLocale(), 'slug' => $action));
        }

        if ($edit === 'edit') {
            return $this->render('timezoneedit/index.html.twig', array(
                'form' => $form->createView(),
                'title' => 'Timezone Selection'
            ));
        } else {
            return $this->render('timezone/index.html.twig', array(
                'form' => $form->createView(),
                'title' => 'Timezone Selection'
            ));
        }
    }

     /**
     * @Route("/{_locale}/{slug}",
     *     name="verifysettingspage",
     *     requirements={"slug"="verify"},
     *     defaults={"_locale": "en"}
     * )
     */
    public function verifySettingsAction(Request $request, $slug, SessionInterface $session)
    {
        $task = new eFaInitTask();

        $form = $this->createForm(VerifySettingsTaskType::class, $task);

        $form->handleRequest($request);

        $ipv4addressflag=false;
        $ipv4netmaskflag=false;
        $ipv4gatewayflag=false;
        $ipv6addressflag=false;
        $ipv6prefixflag=false;
        $ipv6gatewayflag=false;
        $dns1flag=false;
        $dns2flag=false;
        $errormessage='';

        if ($form->isSubmitted() && $form->isValid()) {
            $task = $form->getData();

            $isValid=true;

            // Verify setting groups for sanity and completeness, highlight in red any that need attention
            if ($session->get('configipv4') === '1') {
                if ($session->get('ipv4address') == '') {
                    $isValid=false;
                    $ipv4addressflag=true;
                }
                if ($session->get('ipv4netmask') == '') {
                    $isValid=false;
                    $ipv4netmaskflag=true;
                }
                if ($session->get('ipv4gateway') == '') {
                    $isValid=false;
                    $ipv4gatewayflag=true;
                }
            } 
            if ($session->get('configipv6') === '1') {
                if ($session->get('ipv6address') == '') {
                    $isValid=false;
                    $ipv6addressflag=true;
                }
                if ($session->get('ipv6prefix') == '') {
                    $isValid=false;
                    $ipv6prefixflag=true;
                }
                if ($session->get('ipv6gateway') == '') {
                    $isValid=false;
                    $ipv6gatewayflag=true;
                }
            } 

            if ($session->get('configrecursion') === '0') {
                if ($session->get('dns1') == '') {
                    $isValid=false;
                    $dns1flag=true;
                }
                if ($session->get('dns2') == '') {
                    $isValid=false;
                    $dns2flag=true;
                }
            } 

            if ($isValid === true) {
                // Do it!
                eFaInitController::eFaConfigure($session);

                return new Response('');
         
            } else {
               $errormessage = 'Please fix the items above before continuing.';
            }
        }

        return $this->render('verifysettings/index.html.twig', array(
            'form'            => $form->createView(),
            'title'           => 'Verify Settings',
            'language'        => $session->get('locale'),
            'hostname'        => $session->get('hostname'),
            'domainname'      => $session->get('domainname'),
            'email'           => $session->get('email'),
            'interface'       => $session->get('interface'),
            'configipv4'      => $session->get('configipv4'),
            'ipv4address'     => $session->get('ipv4address'), 'ipv4addressflag' => $ipv4addressflag,
            'ipv4netmask'     => $session->get('ipv4netmask'), 'ipv4netmaskflag' => $ipv4netmaskflag,
            'ipv4gateway'     => $session->get('ipv4gateway'), 'ipv4gatewayflag' => $ipv4gatewayflag,
            'configipv6'      => $session->get('configipv6'),
            'ipv6address'     => $session->get('ipv6address'), 'ipv6addressflag' => $ipv6addressflag,
            'ipv6prefix'      => $session->get('ipv6prefix'),  'ipv6prefixflag'    => $ipv6prefixflag,
            'ipv6gateway'     => $session->get('ipv6gateway'), 'ipv6gatewayflag' => $ipv6gatewayflag,
            'configrecursion' => $session->get('configrecursion'),
            'dns1'            => $session->get('dns1'), 'dns1flag' => $dns1flag,
            'dns2'            => $session->get('dns2'), 'dns2flag' => $dns2flag,
            'webusername'     => $session->get('webusername'),
            'cliusername'     => $session->get('cliusername'),
            'configvirtual'   => $session->get('configvirtual'),
            'configutc'       => $session->get('configutc'),
            'timezone'        => $session->get('timezone'),
            'mailserver'      => $session->get('mailserver'),
            'ianacode'        => $session->get('ianacode'),
            'orgname'         => $session->get('orgname'),
            'errormessage'    => $errormessage,
        ));
    }
    
    private function eFaConfigure(SessionInterface $session) 
    {
        $progress = 0;
        $progressStep = 4;
        eFaInitController::progressBar($progress, $progress);

        $output = '<br/>eFa -- Starting MariaDB...<br/>';

        // Start MariaDB
        $process = new Process('sudo /usr/sbin/eFa-Commit --startmariadb');

        try {
            $process->mustRun();

            $output = $process->getOutput() . '<br/> eFa -- Started MariaDB<br/>' . $output;
            
            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
             eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error starting MariaDB");
             return;
        }

        $progress += $progressStep;

        $process = new Process('sudo /usr/sbin/eFa-Commit --confighost --ipv4address=' . $session->get('ipv4address') . ' --hostname=' . $session->get('hostname') . ' --domainname=' . $session->get('domainname') . ' --ipv6address=' . $session->get('ipv6address'));

        $output = '<br/>eFa -- Configuring host and domain...<br/>' . $output;

        try {
            $process->mustRun();

            $output = $process->getOutput() . '<br/> eFa -- Configured host and domain<br/>' . $output;
            
            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error configuring host and domain");
            return;
        }

        $progress += $progressStep;

        $process = new Process('sudo /usr/sbin/eFa-Commit --configdns --enablerecursion=' . $session->get('configrecursion') . ' --dnsip1=' . $session->get('dns1') . ' --dnsip2=' . $session->get('dns2'));

        $output = '<br/>eFa -- Configuring DNS...<br/>' . $output;

        try {
            $process->mustRun();
            
            $output = $process->getOutput() . '<br/> eFa -- DNS Configured<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error configuring DNS");
            return;
        }

        $progress += $progressStep;

        $process = new Process('sudo /usr/sbin/eFa-Commit --configip --interface=' . $session->get('interface') . ' --ipv4address=' . $session->get('ipv4address') . ' --ipv4netmask=' . $session->get('ipv4netmask') . ' --ipv4gateway=' . $session->get('ipv4gateway') . ' --ipv6address=' . $session->get('ipv6address') . ' --ipv6mask=' . $session->get('ipv6mask') . ' --ipv6gateway=' . $session->get('ipv6gateway') . ' --dnsip1=' . $session->get('dns1') . ' --dnsip2=' . $session->get('dns2'));

        $output = '<br/>eFa -- Configuring interface...<br/>' . $output;

        try {
            $process->mustRun();

            $output = $process->getOutput() . '<br/> eFa -- Interface configured<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error configuring interface");
            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Generating host keys (this may take a while)...<br/>' . $output;

        eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --genhostkeys');
            $process->setTimeout($this->timeout);
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/>eFa -- Generated host keys<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error generating host keys");
            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Configuring Timezone<br/>' . $output;

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --configtzone --timezone=' . $session->get('timezone') . ' --isutc=' . $session->get('configutc'));
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- Timezone configured<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error setting timezone");
            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Writing IANA code to freshclam config<br/>' . $output;

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --configiana --ianacode=' . $session->get('ianacode'));
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- Wrote IANA code to freshclam config<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error writing IANA code to freshclam config");
            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Configuring razor<br/>' . $output;

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --configrazor');
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- Configured razor<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error configuring razor");
            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Updating AV and SA rules...this may take a while...<br/>' . $output;

        try {
            $process = new Process("sudo /usr/sbin/eFa-Commit --configclam");
            $process->setTimeout($this->timeout);
            $process->start();
            
            foreach($process as $type => $data) {
                $output = $data . $output;
                eFaInitController::progressBar($progress, $progress, $output);
            }

            $process = new Process("sudo /usr/sbin/eFa-Commit --updatesa");
            $process->setTimeout($this->timeout);
            $process->start();
            
            $fold = '';
            foreach($process as $type => $data) {
                $fold .= $data;
                if ( strlen($fold) > 80 ) {
                   $output = $fold . "\n" . $output;
                   $fold = '';
                   eFaInitController::progressBar($progress, $progress, $output);
                }
            }

            $output = '<br/> eFa -- Updated AV and SA rules<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error updating AV and SA rules");
            return;
        }
 
        $progress += $progressStep;

        $output = '<br/>eFa -- Running GeoIP update...<br/>' . $output;

        try {
            $process = new Process("sudo /usr/sbin/eFa-Commit --configgeoip");
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- GeoIP updated<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error running GeoIP update");
            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Configure transport<br/>' . $output;

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --configtransport --domainname=' . $session->get('domainname') . ' --mailserver=' . $session->get('mailserver') . ' --adminemail=' . $session->get('email'));
            $process->mustRun();

            $output = $process->getOutput() . $output;
            
            $output = '<br/> eFa -- Transport configured<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error configuring transport");
            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Configuring Spamassassin<br/>' . $output;
        
        eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --configsa --orgname=' . $session->get('orgname'));
            $process->setTimeout($this->timeout);
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- Spamassassin configured<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error configuring spamassassin");
            return;
        }
 
        $progress += $progressStep;

        $output = '<br/>eFa -- Configuring MailScanner<br/>' . $output;

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --configmailscanner --orgname=' . $session->get('orgname') . ' --adminemail=' . $session->get('email') . ' --hostname=' . $session->get('hostname') . ' --domainname=' . $session->get('domainname'));

            $process->mustRun();

            $output = $process->getOutput() . $output;
            
            $output = '<br/> eFa -- MailScanner configured<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error configuring mailscanner");
            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Configuring MailWatch<br/>' . $output;

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --configmailwatch --hostname=' . $session->get('hostname') . ' --domainname=' . $session->get('domainname') . ' --timezone=' . $session->get('timezone') . ' --username=' . $session->get('webusername') . ' --efauserpwd=' . $session->get('webpassword'));

            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- MailWatch configured<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error configuring mailscanner");
            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Configuring SASL<br/>' . $output;

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --configsasl');

            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- SASL configured<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error configuring SASL");
            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Configuring SQLGrey<br/>' . $output;

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --configsqlgrey');

            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- SQLGrey configured<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error configuring SQLGrey");
            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Configuring apache<br/>' . $output;

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --configapache --adminemail=' . $session->get('email'));

            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- Apache configured<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error configuring Apache");
            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Configuring yum-cron<br/>' . $output;

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --configyumcron --hostname=' . $session->get('hostname') . ' --domainname=' . $session->get('domainname') . ' --adminemail=' . $session->get('email'));

            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- yum-cron configured<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error configuring yum-cron");
            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Locking down root<br/>' . $output;

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --configroot');

            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- Root locked down<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error locking down root");

            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Configuring CLI<br/>' . $output;

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --configcli --cliusername=' .  $session->get('cliusername') . ' --efaclipwd=' . $session->get('clipassword'));

            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- Configured CLI<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error configuring CLI");

            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Configuring self-signed cert<br/>' . $output;

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --configcert');

            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- Configured self-signed cert<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error configuring self-signed cert");

            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Locking down mysql <br/>' . $output;

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --configmysql');

            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- Locked down mysql<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error locking down mysql");
            return;
        }

        $progress += $progressStep;

        $output = '<br/>eFa -- Finalizing configuration<br/>' . $output;

        eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --finalize --configvirtual=' .  $session->get('configvirtual'));

            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- Configuration Complete!<br/>' . $output;

            eFaInitController::progressBar($progress, $progress + $progressStep, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error finalizing configuration");
            return;
        }

        $progress += $progressStep;
        $buffer = '<br/>eFa -- Rebooting...Please visit after reboot is complete:<br/>';
        if ( $session->get('ipv4address') != '' ) {
            $buffer .= '<a href="https://' . $session->get('ipv4address') . '">https://' . $session->get('ipv4address') . '</a><br/>';
        }
        if ( $session->get('ipv6address') != '' ) {
            $buffer .= '<a href="https://' . $session->get('ipv6address') . '">https://' . $session->get('ipv6address') . '</a><br/>';
        }
        $output = $buffer . $output;


        eFaInitController::progressBar(100, 100, $output);

        try {
            $process = new Process('sudo /usr/sbin/eFa-Commit --rebootsys'));

            $process->mustRun();

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar($progress, $progress + $progressStep, $output, "Error rebooting, please reboot manually");
            return;
        }

        return;
    }
    
    private function progressBar($oldVal, $val, $output='', $error='')
    {
        for($i=$oldVal; $i<=$val; $i++)
        {
            echo '
                <div style="margin:0;color: #000;font-family: Arial, Helvetica, sans-serif;font-size: 16px;line-height: 1.5em;">
                    <div style="text-align: center; width:1100px; margin: 0 auto;">
                        <div style="position: absolute; width:1100px;">
                            <div style="background-color: #999999; -webkit-border-radius: 15px 15px 0 0; -moz-border-radius: 15px 15px 0 0;border-radius: 15px 15px 0 0;color: #222; font-size: 28px; padding: 15px 15px; margin: 0;text-align: center; border: 2px solid #000000;border-bottom: 0;">
                                <h1>Configuring System...</h1>
                            </div>
                            <div style="padding: 15px 15px; border: solid 2px #000;border-top: 0;-webkit-border-radius: 0 0 15px 15px;-moz-border-radius: 0 0 15px 15px; border-radius: 0 0 15px 15px;">
                               <div style="color: #000; list-style: none; background-color: #009; border: solid 2px #000; -webkit-border-radius: 15px; -moz-border-radius: 15px; border-radius: 15px;">
                                    <div style="-webkit-border-radius: 15px; -moz-border-radius: 15px; border-radius: 15px;width:'.$i.'%;background:linear-gradient(to bottom, rgba(125,126,125,1) 0%,rgba(14,14,14,1) 100%); ;height:35px;">&nbsp;
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                 </div>
             ';

             ob_flush(); 
             flush();
             usleep(10000);
         }

         if ($output !== '')
         {
             echo '
                 <div style="margin: 0; color: #000;font-family: Arial, Helvetica, sans-serif;font-size: 16px;line-height: 1.5em; text-align: center;">
                      <div style="width: 1100px; margin: 0px auto; text-align: center;">
                          <div style="position: absolute; width:1100px; height: 600px; margin: 250px auto; font-size: 24px; color: #000; list-style: none; background-color: #FFF; border: solid 2px #000; -webkit-border-radius: 15px; -moz-border-radius: 15px; border-radius: 15px; text-align: left">
                              <div style="height: 580px; margin: 15px; overflow: scroll">
                                  <h3>'.$output.'</h3>
                              </div>
                          </div>
                      </div>
                 </div>
             ';
             ob_flush();
             flush();
         }

         if ($error !== '') 
         {
             echo '
                 <div style="margin: 0; color: #000;font-family: Arial, Helvetica, sans-serif;font-size: 16px;line-height: 1.5em; text-align: center;">
                      <div style="width: 1100px; margin: 0px auto; text-align: center;">
                          <div style="position: absolute; width:1100px; margin: 900px auto 0px auto; font-size: 24px; color: #FFF; list-style: none; background-color: #900; border: solid 2px #000; -webkit-border-radius: 15px; -moz-border-radius: 15px; border-radius: 15px; text-align: center">
                              <h2>'.$error.'</h2>
                          </div>
                      </div>
                 </div>
             ';
             ob_flush();
             flush();
         }

         return;
    }
}
?>
