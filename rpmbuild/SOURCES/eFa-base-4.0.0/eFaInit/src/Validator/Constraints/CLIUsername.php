<?php 

// src/AppBundle/Validator/Constraints/CLIUsername.php
namespace App\Validator\Constraints;

use Symfony\Component\Validator\Constraint;

/**
 * @Annotation
 */
class CLIUsername extends Constraint
{
    public $message = 'CLI Username already exists or is not alphanumeric (up to 30 characters starting with a letter or _), please choose a different name.';
}

?>
