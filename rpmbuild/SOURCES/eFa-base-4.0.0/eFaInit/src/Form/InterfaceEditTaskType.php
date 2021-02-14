<?php
// src/App/Form/InterfaceEditTaskType.php

namespace App\Form;

use App\Entity\eFaInitTask;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;

class InterfaceEditTaskType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('Interface', ChoiceType::class, array(
                'choices'  => $options['varChoices'],
                'expanded' => false,
                'multiple' => false,
            ))
            ->add('Save', SubmitType::class)
        ;
    }
    public function configureOptions(OptionsResolver $resolver)
    {
        $resolver->setDefaults(array(
            'data_class' => eFaInitTask::class,
            'csrf_token_id' => 'interface_task'
        ));
        $resolver->setRequired('varProperty');
        $resolver->setRequired('varChoices');
    }
}
?>
