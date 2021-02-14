<?php 

// src/AppBundle/Validator/Constraints/UsernameOrEmail.php
namespace App\Validator\Constraints;

use Symfony\Component\Validator\Constraint;

/**
 * @Annotation
 */
class UsernameOrEmail extends Constraint
{
    public $message = 'Web Username must be alphanumeric (up to 30 characters starting with a letter or _) or a valid email address.';
}

?>
