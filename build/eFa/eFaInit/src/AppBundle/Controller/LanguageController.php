<?php

namespace AppBundle\Controller;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;

class LanguageController extends AbstractController
{
    /**
     * @Route("/{_locale}",
     *     name="languagepage",
     *     defaults={"_locale": "en"}
     * )
     */
    public function indexAction()
    {
        return $this->render('default/index.html.twig');
    }
}
