<?php
// src/AppBundle/Controller/LanguageController.php
namespace AppBundle\Controller;

use AppBundle\Entity\EmailTask;
use AppBundle\Form\EmailTaskType;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Component\HttpFoundation\Session\SessionInterface;

class EmailController extends Controller
{
    /**
     * @Route("/{_locale}/email",
     *     name="emailpage",
     *     defaults={"_locale": "en"}
     * )
     */
    public function indexAction(Request $request, SessionInterface $session)
    {
        $emailTask = new EmailTask();
    
        $form = $this->createForm(EmailTaskType::class, $emailTask, array('email' => $session->get('email')));
    
        $form->handleRequest($request);
    
        if ($form->isSubmitted() && $form->isValid()) {
            $emailTask = $form->getData();
            
            // Store domainname in session
            $session->set('email', $emailTask->getTextbox());

            $action = $form->get('Back')->isClicked() ? 'domainnamepage' : 'configipv4page';

            return $this->redirectToRoute($action, array('_locale' => $request->getLocale()));
        }
    
        return $this->render('textbox/index.html.twig', array(
            'form' => $form->createView(),
            'title' => 'Email'
        ));
    }
}
?>
