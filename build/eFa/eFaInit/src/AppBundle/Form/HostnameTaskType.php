<?php
// src/AppBundle/Form/HostnameTaskType.php

namespace AppBundle\Form;

use AppBundle\Entity\HostnameTask;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\TextType;

class HostnameTaskType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('Hostname', TextType::class, array(
                'label'           => 'Please enter a hostname',
                'required'        => false,
                'trim'            => true
            ))
            ->add('Back', SubmitType::class, array(
                'validation_groups' => false
            ))
            ->add('Next', SubmitType::class)
        ;
    }
    public function configureOptions(OptionsResolver $resolver)
    {
        $resolver->setDefaults(array(
            'data_class'    => HostnameTask::class,
            'csrf_token_id' => 'hostname_task'
        ));
    }
}
?>
