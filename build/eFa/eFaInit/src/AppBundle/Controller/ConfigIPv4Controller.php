<?php
// src/AppBundle/Controller/ConfigIPv4Controller.php
namespace AppBundle\Controller;

use AppBundle\Form\ConfigIPv4TaskType;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Component\HttpFoundation\Session\SessionInterface;

class ConfigIPv4Controller extends Controller
{
    /**
     * @Route("/{_locale}/configipv4",
     *     name="configipv4page",
     *     defaults={"_locale": "en"}
     * )
     */
    public function indexAction(Request $request, SessionInterface $session)
    {
    
        $form = $this->createForm(ConfigIPv4TaskType::class);
    
        $form->handleRequest($request);
    
        if ($form->isSubmitted() && $form->isValid()) {

            if ($form->get('Back')->isClicked()) {
                $action='emailpage';
            } elseif ($form->get('Yes')->isClicked()) {
                $action='ipv4addresspage';
                // Store ipv4 config in session
                $session->set('configipv4', '1');
            } else {
                $action='nextitem';
                // Store ipv4 config in session
                $session->set('configipv4', '0');
            } 

            return $this->redirectToRoute($action, array('_locale' => $request->getLocale()));
        }
    
        return $this->render('configipv4/index.html.twig', array(
            'form' => $form->createView(),
        ));
    }
}
?>
