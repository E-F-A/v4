<?php
// src/AppBundle/Form/IPv4addressTaskType.php

namespace AppBundle\Form;

use AppBundle\Entity\IPv4gatewayTask;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\TextType;

class IPv4gatewayTaskType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('Textbox', TextType::class, array(
                'label'           => 'Please enter a valid IPv4 gateway',
                'required'        => false,
                'trim'            => true,
                'data'         => $options['varData']
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
            'data_class'    => IPv4gatewayTask::class,
            'csrf_token_id' => 'ipv4gateway_task'
        ));
        $resolver->setRequired('varData');
    }
}
?>
