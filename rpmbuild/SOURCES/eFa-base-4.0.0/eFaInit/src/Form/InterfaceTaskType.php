<?php
// src/App/Form/InterfaceTaskType.php

namespace App\Form;

use App\Entity\eFaInitTask;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;

class InterfaceTaskType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('Interface', ChoiceType::class, array(
                'choices'  => $options['varChoices']
            ))
            ->add('NextHidden', SubmitType::class, array(
                'validation_groups' => array($options['varProperty']),
            ))
            ->add('Next', SubmitType::class, array(
                'validation_groups' => array($options['varProperty']),
            ))
            ->add('Back', SubmitType::class, array(
                'validation_groups' => false
            ))
        ;
    }
    public function configureOptions(OptionsResolver $resolver)
    {
        $resolver->setDefaults(array(
            'data_class' => eFaInitTask::class,
            'csrf_token_id' => 'interface_task'
        ));
        $resolver->setRequired('varChoices');
        $resolver->setRequired('varProperty');
    }
}
?>
