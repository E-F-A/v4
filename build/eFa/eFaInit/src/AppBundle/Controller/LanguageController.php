<?php
// src/AppBundle/Controller/LanguageController.php
namespace AppBundle\Controller;

use AppBundle\Entity\LanguageTask;
use AppBundle\Form\LanguageTaskType;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Component\HttpFoundation\Session\SessionInterface;

class LanguageController extends Controller
{
    /**
     * @Route("/{_locale}",
     *     name="languagepage",
     *     defaults={"_locale": "en"}
     * )
     */
    public function indexAction(Request $request, SessionInterface $session)
    {
        $languageTask = new LanguageTask();
    
        $form = $this->createForm(LanguageTaskType::class, $languageTask, array('locale' => $request->getLocale()));
    
        $form->handleRequest($request);
    
        if ($form->isSubmitted() && $form->isValid()) {
            $languageTask = $form->getData();

            $session->set('locale', $languageTask->getlanguage()); 

            return $this->redirectToRoute('hostnamepage', array('_locale' => $languageTask->getLanguage()));
        }
    
        return $this->render('language/index.html.twig', array(
            'form' => $form->createView(),
        ));
    }
}
?>
