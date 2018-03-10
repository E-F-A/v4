<?php

namespace AppBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;

class HostnameController extends AbstractController
{
    /**
     * @Route("/{_locale}/hostname",
     *     name="hostnamepage",
     *     defaults={"_locale": "en"}
     * )
     */
    public function indexAction()
    {
        return $this->render('hostname/index.html.twig');
    }
}
