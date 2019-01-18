<?php

// src/AppBundle/Validator/Constraints/CLIUsernameValidator.php
namespace AppBundle\Validator\Constraints;

use Symfony\Component\Process\Process;
use Symfony\Component\Validator\Constraint;
use Symfony\Component\Validator\ConstraintValidator;
use Symfony\Component\Validator\Exception\UnexpectedTypeException;

class CLIUsernameValidator extends ConstraintValidator
{
    public function validate($value, Constraint $constraint)
    {
        if (!$constraint instanceof CLIUsername) {
            throw new UnexpectedTypeException($constraint, CLIUsername::class);
        }

        // custom constraints should ignore null and empty values to allow
        // other constraints (NotBlank, NotNull, etc.) take care of that
        if (null === $value || '' === $value) {
            return;
        }

        if (!is_string($value)) {
            throw new UnexpectedTypeException($value, 'string');
        }
        
        // Test for existing user account
        $process = new Process("sudo cat /etc/passwd");
        $process->mustRun();
        $output = $process->getOutput();
        $output = preg_replace('/:.*$/', '', $output);
        
        if (!preg_match('/^[a-z_][a-z0-9_-]{1,30}+$/', $value, $matches) || preg_match('/' . $value . '/', $output)) {
            $this->context->buildViolation($constraint->message)
                ->setParameter('{{ string }}', $value)
                ->addViolation();
        }
    }
}

?>