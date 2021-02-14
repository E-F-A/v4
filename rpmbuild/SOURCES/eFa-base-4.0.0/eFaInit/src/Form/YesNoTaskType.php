<?php
// src/App/Form/ConfigIPv4TaskType.php

namespace App\Form;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;

class YesNoTaskType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('Yes', SubmitType::class)
            ->add('No', SubmitType::class)
            ->add('Back', SubmitType::class)
        ;
    }
}
?>
