<?php
// src/AppBundle/Form/PasswordTaskType.php

namespace AppBundle\Form;

use AppBundle\Entity\eFaInitTask;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\PasswordType;

class PasswordTaskType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('Passwordbox1', PasswordType::class, array(
                'label'             => $options['varLabel1'],
                'required'          => false,
                'property_path'     => $options['varProperty1'],
            ))
            ->add('Passwordbox2', PasswordType::class, array(
                'label'             => $options['varLabel2'],
                'required'          => false,
                'property_path'     => $options['varProperty2']
            ))
            ->add('NextHidden', SubmitType::class, array(
                'validation_groups' => array($options['varProperty1'], $options['varProperty2'])
            ))
            ->add('Next', SubmitType::class, array(
                'validation_groups' => array($options['varProperty1'], $options['varProperty2'])
            ))
            ->add('Back', SubmitType::class, array(
                'validation_groups' => false
            ))
            ;
    }
    public function configureOptions(OptionsResolver $resolver)
    {
        $resolver->setDefaults(array(
            'data_class'    => eFaInitTask::class,
            'csrf_token_id' => 'eFaInitPassword'
        ));
        $resolver->setRequired('varLabel1');
        $resolver->setRequired('varLabel2');
        $resolver->setRequired('varProperty1');
        $resolver->setRequired('varProperty2');
    }
}
?>
