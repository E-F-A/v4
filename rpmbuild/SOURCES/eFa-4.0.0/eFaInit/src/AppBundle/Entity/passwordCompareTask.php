<?php
// src/AppBundle/Entity/passwordCompareTask.php

namespace AppBundle\Entity;

use Symfony\Component\Validator\Constraints as Assert;

class passwordCompareTask
{
    protected $password1;
    protected $password2;

    public function setPassword1($var)
    {
        $this->password1 = $var;
    }

    public function setPassword2($var)
    {
        $this->password2 = $var;
    }

    /**
     * @Assert\IsFalse(
     *     message="Web and CLI Passwords cannot match"
     * )
     */
    public function isPasswordsSame()
    {
         return $this->password1 === $this->password2;
    }

}
