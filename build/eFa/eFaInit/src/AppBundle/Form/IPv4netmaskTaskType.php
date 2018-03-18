<?php
// src/AppBundle/Form/IPv4netmaskTaskType.php

namespace AppBundle\Form;

use AppBundle\Entity\IPv4netmaskTask;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\TextType;

class IPv4netmaskTaskType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('Textbox', TextType::class, array(
                'label'           => 'Please enter a valid IPv4 netmask',
                'required'        => false,
                'trim'            => true,
                'data'         => $options['ipv4netmask']
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
            'data_class'    => IPv4netmaskTask::class,
            'csrf_token_id' => 'ipv4netmask_task'
        ));
        $resolver->setRequired('ipv4netmask');
    }
}
?>
