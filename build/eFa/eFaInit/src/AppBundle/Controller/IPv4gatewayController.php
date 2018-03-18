<?php
// src/AppBundle/Controller/LanguageController.php
namespace AppBundle\Controller;

use AppBundle\Entity\IPv4gatewayTask;
use AppBundle\Form\IPv4gatewayTaskType;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Component\HttpFoundation\Session\SessionInterface;

class IPv4gatewayController extends Controller
{
    /**
     * @Route("/{_locale}/ipv4gateway",
     *     name="ipv4gatewaypage",
     *     defaults={"_locale": "en"}
     * )
     */
    public function indexAction(Request $request, SessionInterface $session)
    {
        $task = new IPv4gatewayTask();
    
        $form = $this->createForm(IPv4gatewayTaskType::class, $task, array('varData' => $session->get('ipv4gateway')));
    
        $form->handleRequest($request);
    
        if ($form->isSubmitted() && $form->isValid()) {
            $task = $form->getData();
            
            $session->set('ipv4gateway', $task->getTextbox());

            $action = $form->get('Back')->isClicked() ? 'ipv4netmaskpage' : 'nextitem';

            return $this->redirectToRoute($action, array('_locale' => $request->getLocale()));
        }
    
        return $this->render('textbox/index.html.twig', array(
            'form' => $form->createView(),
            'title' => 'IPv4 Gateway'
        ));
    }
}
?>
