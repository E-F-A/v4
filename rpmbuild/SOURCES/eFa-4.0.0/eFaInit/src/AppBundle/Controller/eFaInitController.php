<?php
// src/AppBundle/Controller/eFaInitController.php
namespace AppBundle\Controller;

use AppBundle\Entity\eFaInitTask;
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
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Component\HttpFoundation\Session\SessionInterface;

class eFaInitController extends AbstractController
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
        default:
            return $this->redirectToRoute('languagepage', array('_locale' => 'en'));
        break;
        }
    }

    /**
     * @Route("/{_locale}/{slug}",
     *     name="textboxpage",
     *     requirements={"slug"="hostname|domainname|email|ipv4address|ipv4netmask|ipv4gateway|ipv6address|ipv6mask|ipv6gateway|dns1|dns2|webusername|cliusername|mailserver|ianacode|orgname"},
     *     defaults={"_locale": "en", "edit" = null}
     * )
     * @Route("/{_locale}/{slug}/{edit}",
     *     name="textboxeditpage",
     *     requirements={"slug"="hostname|domainname|email|ipv4address|ipv4netmask|ipv4gateway|ipv6address|ipv6mask|ipv6gateway|dns1|dns2|webusername|cliusername|mailserver|ianacode|orgname", "edit"="edit"},
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
                    'varProperty' => 'Domainname'
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
                    'varProperty' => 'Email'
                );
                $varTitle     = 'Email';
                $nextSlug     = 'configipv4';
                $nextPage     = 'yesnopage';
                $previousSlug = 'domainname';
                $previousPage = 'textboxpage';
            break;
            case "ipv4address":
                $options = array(
                    'varLabel'    => 'Please enter a valid IPv4 address',
                    'varProperty' => 'IPv4address'
                );
                $varTitle     = 'IPv4 Address';
                $nextSlug     = 'ipv4netmask';
                $nextPage     = 'textboxpage';
                $previousSlug = 'configipv4';
                $previousPage = 'yesnopage';
            break;
            case "ipv4netmask":
                $options = array(
                    'varLabel'    => 'Please enter a valid IPv4 netmask',
                    'varProperty' => 'IPv4netmask'
                );
                $varTitle     = 'IPv4 Netmask';
                $nextSlug     = 'ipv4gateway';
                $nextPage     = 'textboxpage';
                $previousSlug = 'ipv4address';
                $previousPage = 'textboxpage';
            break;
            case "ipv4gateway":
                $options = array(
                    'varLabel'    => 'Please enter a valid IPv4 gateway',
                    'varProperty' => 'IPv4gateway'
                );
                $varTitle     = 'IPv4 Gateway';
                $nextSlug     = 'configipv6';
                $nextPage     = 'yesnopage';
                $previousSlug = 'ipv4netmask';
                $previousPage = 'textboxpage';
            break;
             case "ipv6address":
                $options = array(
                    'varLabel'    => 'Please enter a valid IPv6 address',
                    'varProperty' => 'IPv6address'
                );
                $varTitle     = 'IPv6 Address';
                $nextSlug     = 'ipv6mask';
                $nextPage     = 'textboxpage';
                $previousSlug = 'configipv6';
                $previousPage = 'yesnopage';
            break;
            case "ipv6mask":
                $options = array(
                    'varLabel'    => 'Please enter a valid IPv6 mask',
                    'varProperty' => 'IPv6mask'
                );
                $varTitle     = 'IPv6 Mask';
                $nextSlug     = 'ipv6gateway';
                $nextPage     = 'textboxpage';
                $previousSlug = 'ipv6address';
                $previousPage = 'textboxpage';
            break;
            case "ipv6gateway":
                $options = array(
                    'varLabel'    => 'Please enter a valid IPv6 gateway',
                    'varProperty' => 'IPv6gateway'
                );
                $varTitle     = 'IPv6 Gateway';
                $nextSlug     = 'configrecursion';
                $nextPage     = 'yesnopage';
                $previousSlug = 'ipv6mask';
                $previousPage = 'textboxpage';
            break;
            case "dns1":
                $options = array(
                    'varLabel'    => 'Please enter the primary DNS address',
                    'varProperty' => 'DNS1'
                );
                $varTitle     = 'Primary DNS';
                $nextSlug     = 'dns2';
                $nextPage     = 'textboxpage';
                $previousSlug = 'configrecursion';
                $previousPage = 'yesnopage';
            break;
            case "dns2":
                $options = array(
                    'varLabel'    => 'Please enter the secondary DNS address',
                    'varProperty' => 'DNS2'
                );
                $varTitle     = 'Secondary DNS';
                $nextSlug     = 'webusername';
                $nextPage     = 'textboxpage';
                $previousSlug = 'dns1';
                $previousPage = 'textboxpage';
            break;
            case "webusername":
                $options = array(
                    'varLabel'    => 'Please enter the username for the admin web interface',
                    'varProperty' => 'Webusername'
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
                    'varProperty' => 'CLIusername'
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
                    'varProperty' => 'Mailserver'
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
                    'varProperty' => 'IANAcode'
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
                    'varProperty' => 'Orgname'
                );
                $varTitle     = 'Organization Name';
                $nextSlug     = 'verify';
                $nextPage     = 'verifysettingspage';
                $previousSlug = 'ianacode';
                $previousPage = 'textboxpage';
            break;

        }
        $options['varData'] = $session->get($slug);

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
                $action = $form->get('Next')->isClicked() ? $nextSlug : $previousSlug;
                $page   = $form->get('Next')->isClicked() ? $nextPage : $previousPage;
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
                $previousPage = 'textboxpage';
                $previousSlug = 'email';
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
                    'varProperty1'  => 'Webpassword1',
                    'varProperty2' => 'Webpassword2'
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
                    'varProperty1'  => 'CLIpassword1',
                    'varProperty2' => 'CLIpassword2'
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
            
            if ($edit === 'edit') {
                $action = 'verify';
                $page   = 'verifysettingspage';
            } else {
                $action = $form->get('Next')->isClicked() ? $nextSlug : $previousSlug;
                $page   = $form->get('Next')->isClicked() ? $nextPage : $previousPage;
            }

            return $this->redirectToRoute($page, array('_locale' => $request->getLocale(), 'slug' => $action));
        }
        
        if ($edit === 'edit') {
            return $this->render('passwordeditbox/index.html.twig', array(
                'form' => $form->createView(),
                'title' => $varTitle,
            ));
        } else {
            return $this->render('passwordbox/index.html.twig', array(
                'form' => $form->createView(),
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
                $action = $form->get('Next')->isClicked() ? 'mailserver' : 'configutc';
                $page   = $form->get('Next')->isClicked() ? 'textboxpage' : 'yesnopage';
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
        $ipv6maskflag=false;
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
                if ($session->get('ipv6mask') == '') {
                    $isValid=false;
                    $ipv6maskflag=true;
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
                // Configure eFa
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
            'configipv4'      => $session->get('configipv4'),
            'ipv4address'     => $session->get('ipv4address'), 'ipv4addressflag' => $ipv4addressflag,
            'ipv4netmask'     => $session->get('ipv4netmask'), 'ipv4netmaskflag' => $ipv4netmaskflag,
            'ipv4gateway'     => $session->get('ipv4gateway'), 'ipv4gatewayflag' => $ipv4gatewayflag,
            'configipv6'      => $session->get('configipv6'),
            'ipv6address'     => $session->get('ipv6address'), 'ipv6addressflag' => $ipv6addressflag,
            'ipv6mask'        => $session->get('ipv6mask'),    'ipv6maskflag'    => $ipv6maskflag,
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

}
?>
