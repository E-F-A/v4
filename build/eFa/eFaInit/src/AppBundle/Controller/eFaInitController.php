<?php
// src/AppBundle/Controller/eFaInitController.php
namespace AppBundle\Controller;

use AppBundle\Entity\eFaInitTask;
use AppBundle\Form\LanguageTaskType;
use AppBundle\Form\YesNoTaskType;
use AppBundle\Form\TextboxTaskType;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Component\HttpFoundation\Session\SessionInterface;

class eFaInitController extends AbstractController
{
    /**
     * @Route("/{_locale}",
     *     name="languagepage",
     * )
     */
    public function indexAction(Request $request, SessionInterface $session)
    {
        $task = new eFaInitTask();
    
        $form = $this->createForm(LanguageTaskType::class, $task, array('locale' => $request->getLocale()));
    
        $form->handleRequest($request);
    
        if ($form->isSubmitted() && $form->isValid()) {
            $languageTask = $form->getData();

            $session->set('locale', $task->getLanguage()); 

            return $this->redirectToRoute('textboxpage', array('_locale' => $task->getLanguage(), 'slug' => 'hostname'));
        }
    
        return $this->render('language/index.html.twig', array(
            'form' => $form->createView(),
        ));
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
        default:
            return $this->redirectToRoute('languagepage', array('_locale' => 'en'));
        break;
        }
    }

    /**
     * @Route("/{_locale}/{slug}",
     *     name="textboxpage",
     *     requirements={"slug"="hostname|domainname|email|ipv4address|ipv4netmask|ipv4gateway"},
     *     defaults={"_locale": "en"}
     * )
     */
    public function textboxAction(Request $request, $slug, SessionInterface $session)
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
                $previousSlug = 'language';
            break;
            case "domainname":
                $options = array(
                    'varLabel'    => 'Please enter a domain name',
                    'varProperty' => 'Domainname'
                );
                $varTitle     = 'Domain Name';
                $nextSlug     = 'email';
                $previousSlug = 'hostname';
            break;
            case "email":
                $options = array(
                    'varLabel'    => 'Please enter an email address for important notifications',
                    'varProperty' => 'Email'
                );
                $varTitle     = 'Email';
                $nextSlug     = 'configipv4';
                $previousSlug = 'domainname';
            break;
            case "ipv4address":
                $options = array(
                    'varLabel'    => 'Please enter a valid IPv4 address',
                    'varProperty' => 'IPv4address'
                );
                $varTitle     = 'IPv4 Address';
                $nextSlug     = 'ipv4netmask';
                $previousSlug = 'configipv4';
            break;
            case "ipv4netmask":
                $options = array(
                    'varLabel'    => 'Please enter a valid IPv4 netmask',
                    'varProperty' => 'IPv4netmask'
                );
                $varTitle     = 'IPv4 Netmask';
                $nextSlug     = 'ipv4gateway';
                $previousSlug = 'ipv4address';
            break;
            case "ipv4gateway":
                $options = array(
                    'varLabel'    => 'Please enter a valid IPv4 gateway',
                    'varProperty' => 'IPv4gateway'
                );
                $varTitle     = 'IPv4 Gateway';
                $nextSlug     = 'nextitem';
                $previousSlug = 'ipv4netmask';
            break;
 
        }
        $options['varData'] = $session->get($slug);

        $form = $this->createForm(TextboxTaskType::class, $task, $options);

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $task = $form->getData();

            // Store hostname in session
            $getMethod = "get" . $slug;
            $session->set($slug, $task->$getMethod());

            $action = $form->get('Next')->isClicked() ? $nextSlug : $previousSlug;

            if ($action === 'language') {
                return $this->redirectToRoute('languagepage', array('_locale' => $request->getLocale()));
            } elseif ($action === 'configipv4') {
                return $this->redirectToRoute('configipv4page', array('_locale' => $request->getLocale()));
            } else {
                return $this->redirectToRoute('textboxpage', array('_locale' => $request->getLocale(), 'slug' => $action));
            }
        }

        return $this->render('textbox/index.html.twig', array(
            'form' => $form->createView(),
            'title' => $varTitle
        ));
    }

    /**
     * @Route("/{_locale}/configipv4",
     *     name="configipv4page",
     *     defaults={"_locale": "en"}
     * )
     */
    public function configipv4Action(Request $request, SessionInterface $session)
    {

        $form = $this->createForm(YesNoTaskType::class);

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {

            if ($form->get('Back')->isClicked()) {
                $action='textboxpage';
                $slug='email';
            } elseif ($form->get('Yes')->isClicked()) {
                $action='textboxpage';
                $slug='ipv4address';
                // Store ipv4 config in session
                $session->set('configipv4', '1');
            } else {
                $action='nextitem';
                // Store ipv4 config in session
                $session->set('configipv4', '0');
            }

            return $this->redirectToRoute($action, array('_locale' => $request->getLocale(), 'slug' => $slug));
        }

        return $this->render('yesno/index.html.twig', array(
            'form' => $form->createView(),
            'title' => 'Configure IPv4',
            'question' => 'Do you want to set a static IPv4 address?'
        ));
    }
}
?>
