<?php
// src/AppBundle/Form/PasswordTaskType.php

namespace AppBundle\Form;

use AppBundle\Entity\eFaInitTask;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\PasswordType;
use Symfony\Component\Form\Extension\Core\Type\TextType;

class PasswordEditTaskType extends AbstractType
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
            ->add('Passwordboxhidden', TextType::class, array(
                'label'             => $options['varLabel3'],
                'required'          => false,
                'property_path'     => $options['varProperty3'],
                'data'              => $options['varData3'],
            ))
            ->add('Save', SubmitType::class, array(
                'validation_groups' => array($options['varProperty1'], $options['varProperty2'], $options['varProperty3'])
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
        $resolver->setRequired('varLabel3');
        $resolver->setRequired('varProperty1');
        $resolver->setRequired('varProperty2');
        $resolver->setRequired('varProperty3');
        $resolver->setRequired('varData3');
    }
}
?>
