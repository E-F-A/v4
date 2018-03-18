<?php
// src/AppBundle/Controller/LanguageController.php
namespace AppBundle\Controller;

use AppBundle\Entity\DomainnameTask;
use AppBundle\Form\DomainnameTaskType;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Component\HttpFoundation\Session\SessionInterface;

class DomainnameController extends Controller
{
    /**
     * @Route("/{_locale}/domainname",
     *     name="domainnamepage",
     *     defaults={"_locale": "en"}
     * )
     */
    public function indexAction(Request $request, SessionInterface $session)
    {
        $domainnameTask = new DomainnameTask();
    
        $form = $this->createForm(DomainnameTaskType::class, $domainnameTask, array('domainname' => $session->get('domainname')));
    
        $form->handleRequest($request);
    
        if ($form->isSubmitted() && $form->isValid()) {
            $domainnameTask = $form->getData();
            
            // Store domainname in session
            $session->set('domainname', $domainnameTask->getTextbox());

            $action = $form->get('Back')->isClicked() ? 'hostnamepage' : 'emailpage';

            return $this->redirectToRoute($action, array('_locale' => $request->getLocale()));
        }
    
        return $this->render('textbox/index.html.twig', array(
            'form' => $form->createView(),
            'title' => "Domain Name"
        ));
    }
}
?>
