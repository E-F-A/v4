<?php
// src/AppBundle/Controller/LanguageController.php
namespace AppBundle\Controller;

use AppBundle\Entity\HostnameTask;
use AppBundle\Form\HostnameTaskType;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;

class HostnameController extends Controller
{
    /**
     * @Route("/{_locale}/hostname",
     *     name="hostnamepage",
     *     defaults={"_locale": "en"}
     * )
     */
    public function indexAction(Request $request)
    {
        $hostnameTask = new HostnameTask();
    
        $form = $this->createForm(HostnameTaskType::class, $hostnameTask);
    
        $form->handleRequest($request);
    
        if ($form->isSubmitted() && $form->isValid()) {
            $hostnameTask = $form->getData();

            $action = $form->get('Back')->isClicked() ? 'languagepage' : 'nextitem';

            return $this->redirectToRoute($action, array('_locale' => $request->getLocale()));
        }
    
        return $this->render('hostname/index.html.twig', array(
            'form' => $form->createView(),
        ));
    }
}
?>
