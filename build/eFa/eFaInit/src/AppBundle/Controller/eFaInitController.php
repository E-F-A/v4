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
     *     requirements={"slug"="hostname|domainname|email|ipv4address|ipv4netmask|ipv4gateway|ipv6address|ipv6mask|ipv6gateway"},
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
                $nextSlug     = 'configipv6';
                $nextPage     = 'yesnopage';
                $previousSlug = 'ipv6mask';
                $previousPage = 'textboxpage';
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
            $page   = $form->get('Next')->isClicked() ? $nextPage : $previousPage;

            return $this->redirectToRoute($page, array('_locale' => $request->getLocale(), 'slug' => $action));
        }

        
        return $this->render('textbox/index.html.twig', array(
            'form' => $form->createView(),
            'title' => $varTitle
        ));
    }

    /**
     * @Route("/{_locale}/{slug}",
     *     name="yesnopage",
     *     requirements={"slug"="configipv4|configipv6"},
     *     defaults={"_locale": "en"}
     * )
     */
    public function yesnoAction(Request $request, $slug, SessionInterface $session)
    {

        $form = $this->createForm(YesNoTaskType::class);

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
                $noSlug       = 'nextitem';
                $noPage       = 'nextpage';
                $previousPage = 'yesnopage';
                $previousSlug = 'configipv4';
            break;
        }

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {

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

            return $this->redirectToRoute($action, array('_locale' => $request->getLocale(), 'slug' => $slug));
        }

        return $this->render('yesno/index.html.twig', array(
            'form' => $form->createView(),
            'title' => $varTitle,
            'question' => $varQuestion
        ));
    }
}
?>
