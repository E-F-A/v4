<?php
// src/AppBundle/Controller/LanguageController.php
namespace AppBundle\Controller;

use AppBundle\Entity\IPv4addressTask;
use AppBundle\Form\IPv4addressTaskType;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Component\HttpFoundation\Session\SessionInterface;

class IPv4addressController extends Controller
{
    /**
     * @Route("/{_locale}/ipv4address",
     *     name="ipv4addresspage",
     *     defaults={"_locale": "en"}
     * )
     */
    public function indexAction(Request $request, SessionInterface $session)
    {
        $ipv4addressTask = new IPv4addressTask();
    
        $form = $this->createForm(IPv4addressTaskType::class, $ipv4addressTask, array('ipv4address' => $session->get('ipv4address')));
    
        $form->handleRequest($request);
    
        if ($form->isSubmitted() && $form->isValid()) {
            $ipv4addressTask = $form->getData();
            
            // Store ipv4 address in session
            $session->set('ipv4address', $ipv4addressTask->getTextbox());

            $action = $form->get('Back')->isClicked() ? 'configipv4page' : 'ipv4netmaskpage';

            return $this->redirectToRoute($action, array('_locale' => $request->getLocale()));
        }
    
        return $this->render('textbox/index.html.twig', array(
            'form' => $form->createView(),
            'title' => 'IPv4 Address'
        ));
    }
}
?>
