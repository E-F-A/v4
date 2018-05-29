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
        eFaInitController::progressBar(0, 0);

        $output = '<br/>eFa -- Starting MariaDB...<br/>';

        // Start MariaDB
        $process = new Process('systemctl restart mariadb');

        try {
            $process->mustRun();

            $output = $process->getOutput() . '<br/> eFa -- Started MariaDB<br/>' . $output;
            
            eFaInitController::progressBar(0, 5, $output);

        } catch (ProcessFailedException $exception) {
             eFaInitController::progressBar(0, 5, $output, "Error starting MariaDB");
             return;
        }
        
        $process = new Process('echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts');

        $output = '<br/>eFa -- Adding ipv4 localhost entry...<br/>' . $output;
 
        try {
            $process->mustRun();

            $output = $process->getOutput() . '<br/> eFa -- ipv4 locahost entry added<br/>' . $output;
            
            eFaInitController::progressBar(5, 10, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar(5, 10, $output, "Error setting ipv4 localhost");
            return;
        }
        
        $process = new Process('echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts');

        $output = '<br/>eFa -- Adding ipv6 localhost entry...<br/>' . $output;

        try {
            $process->mustRun();
            
            $output = $process->getOutput() . '<br/> eFa -- ipv6 locahost entry added<br/>' . $output;
            
            eFaInitController::progressBar(10, 15, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar(10, 15, $output, "Error setting ipv6 localhost");
            return;
        }

        if ($session->get('configipv4') === '1')
        {
            $process = new Process('echo "' . $session->get('ipv4address') . '    ' . $session->get('hostname') . '.' . $session->get('domainname') . '    ' .  $session->get('hostname') .'" >> /etc/hosts');
        
            $output = '<br/>eFa -- Adding ipv4 host entry...<br/>' . $output;
 
            try {
                $process->mustRun();
            
                $output = $process->getOutput() . '<br/> eFa -- ipv4 host entry added<br/>' . $output;

                eFaInitController::progressBar(15, 20, $output);
            } catch (ProcessFailedException $exception) {
                eFaInitController::progressBar(15, 20, $output, "Error setting ipv4 address hostname");
                return;
            }
        }
        
        if ($session->get('configipv6') === '1')
        {
            $process = new Process('echo "' . $session->get('ipv6address') . '    ' . $session->get('hostname') . '.' . $session->get('domainname') . '    ' .  $session->get('hostname') .'" >> /etc/hosts');
 
            $output = '<br/>eFa -- Adding ipv6 host entry...<br/>' . $output;

            try {
                $process->mustRun();
                
                $output = $process->getOutput() . '<br/> eFa -- ipv6 host entry added<br/>' . $output;

                eFaInitController::progressBar(20, 25, $output);

            } catch (ProcessFailedException $exception) {
                eFaInitController::progressBar(20, 25, $output, "Error setting ipv6 address");
                return;
            }
        }
        
        $process = new Process('echo "' . $session->get('hostname') . '.' . $session->get('domainname') . '" > /etc/hostname');

        $output = '<br/>eFa -- Adding hostname to /etc/hosts...<br/>' . $output;

        try {
            $process->mustRun();
                
            $output = $process->getOutput() . '<br/> eFa -- hostname entry added to /etc/hosts<br/>' . $output;

            eFaInitController::progressBar(25, 30, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar(25, 30, $output, "Error setting /etc/hostname");
            return;
        }

        $process = new Process('hostname ' . $session->get('hostname') . '.' . $session->get('domainname'));

        $output = '<br/>eFa -- Setting hostname...<br/>' . $output;

        try {
            $process->mustRun();
            
            $output = $process->getOutput() . '<br/> eFa -- hostname set<br/>' . $output;

            eFaInitController::progressBar(30, 35, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar(30, 35, $output, "Error setting /etc/hostname");
            return;
        }
        
        $process = new Process('echo -e "forward-zone:\n  name: \".\"" > /etc/unbound/conf.d/forwarders.conf');

        $output = '<br/>eFa -- Setting root fowarder for unbound...<br/>' . $output;

        try {
            $process->mustRun();
            
            $output = $process->getOutput() . '<br/> eFa -- root forwarder set for unbound<br/>' . $output;

            eFaInitController::progressBar(30, 35, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar(30, 35, $output, "Error setting root forwarder for unbound");
            return;
        }

        if ($session->get('configrecursion') === '1')
        {
            $process = new Process('echo -e "  forward-first: yes\n" >> /etc/unbound/conf.d/forwarders.conf');

            $output = '<br/>eFa -- Setting recursion for unbound...<br/>' . $output;

            try {
                $process->mustRun();
             
                $output = $process->getOutput() . '<br/> eFa -- recursion set for unbound<br/>' . $output;

                eFaInitController::progressBar(35, 40, $output);

             } catch (ProcessFailedException $exception) {
                 eFaInitController::progressBar(35, 40, $output, "Error setting recursion for unbound");
                 return;
             }
         } else {

            $process = new Process('echo -e "  forward-addr: ' . $session->get('dns1') . '"\n  forward-addr: ' . $session->get('dns2') . '\n" >> /etc/unbound/conf.d/forwarders.conf');

            $output = '<br/>eFa -- Setting dns forwarders for unbound...<br/>' . $output;

            try {
                $process->mustRun();

                $output = $process->getOutput() . '<br/> eFa -- dns forwarders set for unbound<br/>' . $output;

                eFaInitController::progressBar(35, 40, $output);

             } catch (ProcessFailedException $exception) {
                 eFaInitController::progressBar(35, 40, $output, "Error setting forwarders for unbound");
                 return;
             }
        }
        $interface = $session->get('interface');

        if (file_exists('/etc/sysconfig/network-scripts/ifcfg-' . $interface . '.bak'))
        {
            $process = new Process('cp /etc/sysconfig/network-scripts/ifcfg-' . $interface . '.bak /etc/sysconfig/network-scripts/ifcfg-' . $interface);

            $output = '<br/>eFa -- Restoring interface config...<br/>' . $output;

            try {
                $process->mustRun();

                $output = $process->getOutput() . '<br/> eFa -- Interface config restored<br/>' . $output;

                eFaInitController::progressBar(40, 45, $output);

            } catch (ProcessFailedException $exception) {
                 eFaInitController::progressBar(40, 45, $output, "Error restoring interface config");
                return;
            }
        } else {
            $process = new Process('cp /etc/sysconfig/network-scripts/ifcfg-' . $interface . ' /etc/sysconfig/network-scripts/ifcfg-' . $interface . '.bak');

            $output = '<br/>eFa -- Backing up interface config...<br/>' . $output;

            try {
                $process->mustRun();

                $output = $process->getOutput() . '<br/>eFa -- Interface config backed up<br/>' . $output;

                eFaInitController::progressBar(40, 45, $output);

            } catch (ProcessFailedException $exception) {
                 eFaInitController::progressBar(40, 45, $output, "Error backing up interface config");
                return;
            }
       }

        $process = new Process('sed -i "/^BOOTPROTO=/ c\BOOTPROTO=\"none\"" /etc/sysconfig/network-scripts/ifcfg-' . $interface);

        $output = '<br/>eFa -- Setting BOOTPROTO for interface...<br/>' . $output;

        try {
            $process->mustRun();

            $output = $process->getOutput() . '<br/> eFa -- BOOTPROTO set for interface<br/>' . $output;

            eFaInitController::progressBar(45, 50, $output);

        } catch (ProcessFailedException $exception) {
             eFaInitController::progressBar(45, 50, $output, "Error BOOTPROTO for interface");
            return;
        }
        
        if ($session->get('configipv4') === '1')
        {
            $process = new Process('echo -e "IPADDR=\"' . $session->get('ipv4address') . '\"\nNETMASK=\"' . $session->get('ipv4netmask') . '\"\nGATEWAY=\"' . $session->get('ipv4gateway') . '\"" >> /etc/sysconfig/network-scripts/ifcfg-' . $interface);

            $output = '<br/>eFa -- Setting static ipv4 address, netmask, and gateway for interface...<br/>' . $output;

            try {
                $process->mustRun();

                $output = $process->getOutput() . '<br/> eFa -- ipv4 address, netmask, and gateway set for interface<br/>' . $output;

                eFaInitController::progressBar(50, 55, $output);

            } catch (ProcessFailedException $exception) {
                eFaInitController::progressBar(50, 55, $output, "Error setting ipv4 address, netmask, and gateway");
                return;
            }
        }   

        if ($session->get('configipv6') === '1')
        {
            $process = new Process('sed -i "/^IPV6_AUTOCONF=/ c\IPV6_AUTOCONF=\"no\"" /etc/sysconfig/network-scripts/ifcfg-' . $interface);

            $output = '<br/>eFa -- Setting setting ipv6 auto config off...<br/>' . $output;

            try {
                $process->mustRun();

                $output = $process->getOutput() . '<br/> eFa -- set ipv6 auto config off<br/>' . $output;

                eFaInitController::progressBar(55, 60, $output);

            } catch (ProcessFailedException $exception) {
                eFaInitController::progressBar(55, 60, $output, "Error setting ipv6 auto config off");
                return;
            }

            $process = new Process('echo -e "IPV6ADDR=\"' . $session->get('ipv6address') . '/' . $session->get('ipv6prefix') . '\"\nIPV6_DEFAULTGW=\"' . $session->get('ipv6gateway'). '\"" >> /etc/sysconfig/network-scripts/ifcfg-' . $interface);

            $output = '<br/>eFa -- Setting setting ipv6 address and gateway...<br/>' . $output;

            try {
                $process->mustRun();

                $output = $process->getOutput() . '<br/> eFa -- set ipv6 address and gateway<br/>' . $output;

                eFaInitController::progressBar(60, 65, $output);

            } catch (ProcessFailedException $exception) {
                eFaInitController::progressBar(60, 65, $output, "Error setting ipv6 address and gateway");
                return;
            }
        }

        $process = new Process('echo -e "DNS1=\"127.0.0.1\"\nDNS2=\"::1\"" >> /etc/sysconfig/network-scripts/ifcfg-' . $interface);

        $output = '<br/>eFa -- Directing interface DNS to unbound...<br/>' . $output;

        try {
            $process->mustRun();

            $output = $process->getOutput() . '<br/> eFa -- Directed interface DNS to unbound<br/>' . $output;

            eFaInitController::progressBar(65, 70, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar(65, 70, $output, "Error directing interface to unbound");
            return;
        }

        $output = '<br/>eFa -- Generating host keys...<br/>' . $output;

        try {
            $process = new Process('rm -f /etc/ssh/ssh_host_rsa_key && rm -f /etc/ssh/ssh_host_dsa_key && rm -f /etc/ssh/ssh_host_ecdsa_key && rm -f /etc/ssh/ssh_host_ed25519_key');

            $process->mustRun();

            $output = $process->getOutput() . $output;

            $process = new Process('ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N \'\' -t rsa');
            
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $process = new Process('ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N \'\' -t dsa');

            $process->mustRun();

            $output = $process->getOutput() . $output;

            $process = new Process('ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N \'\' -t ecdsa');

            $process->mustRun();

            $output = $process->getOutput() . $output;

            $process = new Process('ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N \'\' -t ed25519');

            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/>eFa -- Generated existing host keys<br/>' . $output;

            eFaInitController::progressBar(70, 75, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar(70, 75, $output, "Error generating host keys");
            return;
        }

        $output = '<br/>eFa -- Generating dhparam...this may take a while...<br/>' . $output;

        eFaInitController::progressBar(75, 75, $output);

        try {
            $process = new Process('openssl dhparam -out /etc/postfix/ssl/dhparam.pem 2048');
            $process->setTimeout(600);
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $process = new Process('postconf -e "smtpd_tls_dh1024_param_file = /etc/postfix/ssl/dhparam.pem"');
            $process->mustRun();
            
            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- Generated dhparam<br/>' . $output;

            eFaInitController::progressBar(75, 80, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar(75, 80, $output, "Error generating dhparam");
            return;
        }

        $output = '<br/>eFa -- Configuring Timezone<br/>' . $output;

        eFaInitController::progressBar(80, 80, $output);

        try {
            $process = new Process('rm -f /etc/localtime');
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $process = new Process('ln -s /usr/share/zoneinfo/' . $session->get('timezone') . ' /etc/localtime');
            $process->mustRun();
            
            $output = $process->getOutput() . $output;

            $process = new Process('');
            $process->mustRun();
            
            $output = $process->getOutput() . $output;

            $process = new Process('timedatectl set-timezone ' . $session->get('timezone'));
            $process->mustRun();
            
            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- Timezone configured<br/>' . $output;

            eFaInitController::progressBar(80, 85, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar(80, 85, $output, "Error setting timezone");
            return;
        }
 
        $output = '<br/>eFa -- Writing IANA code to freshclam config<br/>' . $output;

        eFaInitController::progressBar(85, 85, $output);

        try {
            if(file_exists('/etc/freshclam.conf.bak'))
            {
                $process = new Process('rm -f /etc/freshclam.conf');
                $process->mustRun();

                $output = $process->getOutput() . $output;

                $process = new Process('cp -f /etc/freshclam.conf.bak /etc/freshclam.conf');
                $process->mustRun();

                $output = $process->getOutput() . $output;
            } else {
                $process = new Process('cp -f /etc/freshclam.conf /etc/freshclam.conf.bak');
                $process->mustRun();

                $output = $process->getOutput() . $output;
            }

            $process = new Process('sed -i "/^#DatabaseMirror / c\DatabaseMirror db.' . $session->get('ianacode') . '.clamav.net" /etc/freshclam.conf');
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- Wrote IANA code to freshclam config<br/>' . $output;

            eFaInitController::progressBar(85, 90, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar(85, 90, $output, "Error writing IANA code to freshclam config");
            return;
        }

        $output = '<br/>eFa -- Configuring razor<br/>' . $output;

        eFaInitController::progressBar(90, 90, $output);

        try {
            $process = new Process("su postfix -s /bin/bash -c 'razor-admin -create'");
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $process = new Process("su postfix -s /bin/bash -c 'razor-admin -register'");
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $process = new Process("sed -i '/^debuglevel/ c\debuglevel             = 0' /var/spool/postfix/.razor/razor-agent.conf");
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $process = new Process("chown -R postfix:mtagroup /var/spool/postfix/.razor");
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $process = new Process("chmod ug+s /var/spool/postfix/.razor");
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $process = new Process("chmod ug+rw /var/spool/postfix/.razor/*");
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $output = '<br/> eFa -- Configured razor<br/>' . $output;

            eFaInitController::progressBar(90, 95, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar(90, 95, $output, "Error configuring razor");
            return;
        }

        $output = '<br/>eFa -- Updating AV and SA rules...this may take a while...<br/>' . $output;

        eFaInitController::progressBar(95, 95, $output);

        try {
            $process = new Process("systemctl start clam.scan");
            $process->mustRun();

            $output = $process->getOutput() . $output;

            $process = new Process("freshclam");
            $process->setTimeout(600);
            $process->start();
            
            foreach($process as $type => $data) {
                $output = $data . $output;
                eFaInitController::progressBar(95, 95, $output);
            }

            $process = new Process("/usr/sbin/clamav-unofficial-sigs.sh");
            $process->setTimeout(600);
            $process->start();
            
            foreach($process as $type => $data) {
                $output = $data . $output;
                eFaInitController::progressBar(95, 95, $output);
            }

            $process = new Process("sa-update");
            $process->setTimeout(600);
            $process->start();
            
            foreach($process as $type => $data) {
                $output = $data . $output;
                eFaInitController::progressBar(95, 95, $output);
            }

            $process = new Process("sa-compile");
            $process->setTimeout(600);
            $process->start();
            
            foreach($process as $type => $data) {
                $output = $data . $output;
                eFaInitController::progressBar(95, 95, $output);
            }

            $output = '<br/> eFa -- Updated AV and SA rules<br/>' . $output;

            eFaInitController::progressBar(95, 100, $output);

        } catch (ProcessFailedException $exception) {
            eFaInitController::progressBar(95, 100, $output, "Error updating AV and SA rules");
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
