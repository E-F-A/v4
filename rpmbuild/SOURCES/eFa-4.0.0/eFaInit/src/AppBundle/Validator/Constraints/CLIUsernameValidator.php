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
        $process = new Process("sudo cat /etc/passwd | awk -F\":\" '{print $1}' | grep -e \"^" . $value ."\"");
        $process->mustRun();
        $output = $process->getOutput();

        if (!preg_match('/^[a-z_][a-z0-9_-]{1,30}+$/', $value, $matches) || !empty($output)) {
            $this->context->buildViolation($constraint->message)
                ->setParameter('{{ string }}', $value)
                ->addViolation();
        }
    }
}

?>