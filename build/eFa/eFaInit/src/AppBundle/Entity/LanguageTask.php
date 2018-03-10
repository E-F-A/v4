<?php
// src/AppBundle/Entity/LanguageTask.php

namespace AppBundle\Entity;

use Symfony\Component\Validator\Constraints as Assert;

class LanguageTask
{
    /**
     * @Assert\Locale()
     */
    protected $locale;


    public function getLanguage()
    {
        return $this->locale;
    }

    public function setLanguage($locale)
    {
        $this->locale = $locale;
    }
}
?>
