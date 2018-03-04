<?php

namespace AppBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;

class DefaultController extends AbstractController
{
    /**
     * @Route("/{_locale}",
     *     name="homepage",
     *     defaults={"_locale": "en"}
     * )
     */
    public function indexAction(Request $request)
    {
        return $this->render('default/index.html.twig');
    }
}
