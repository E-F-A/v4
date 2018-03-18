<?php
// src/AppBundle/Controller/LanguageController.php
namespace AppBundle\Controller;

use AppBundle\Entity\IPv4netmaskTask;
use AppBundle\Form\IPv4netmaskTaskType;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Component\HttpFoundation\Session\SessionInterface;

class IPv4netmaskController extends Controller
{
    /**
     * @Route("/{_locale}/ipv4netmask",
     *     name="ipv4netmaskpage",
     *     defaults={"_locale": "en"}
     * )
     */
    public function indexAction(Request $request, SessionInterface $session)
    {
        $ipv4netmaskTask = new IPv4netmaskTask();
    
        $form = $this->createForm(IPv4netmaskTaskType::class, $ipv4netmaskTask, array('ipv4netmask' => $session->get('ipv4netmask')));
    
        $form->handleRequest($request);
    
        if ($form->isSubmitted() && $form->isValid()) {
            $ipv4netmaskTask = $form->getData();
            
            $session->set('ipv4netmask', $ipv4netmaskTask->getTextbox());

            $action = $form->get('Back')->isClicked() ? 'ipv4addresspage' : 'nextitem';

            return $this->redirectToRoute($action, array('_locale' => $request->getLocale()));
        }
    
        return $this->render('textbox/index.html.twig', array(
            'form' => $form->createView(),
            'title' => 'IPv4 Netmask'
        ));
    }
}
?>
