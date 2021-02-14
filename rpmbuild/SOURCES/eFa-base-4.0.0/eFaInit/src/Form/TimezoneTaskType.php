<?php
// src/App/Form/LanguageTaskType.php

namespace App\Form;

use App\Entity\eFaInitTask;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\TimezoneType;

class TimezoneTaskType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('Timezone', TimezoneType::class, array(
                'preferred_choices' => array($options['varData']),
                'expanded' => false,
                'multiple' => false,
                ))
            ->add('Back', SubmitType::class, array(
                'validation_groups' => false
                ))
            ->add('Next', SubmitType::class)
            ->add('NextHidden', SubmitType::class)
        ;
    }
    public function configureOptions(OptionsResolver $resolver)
    {
        $resolver->setDefaults(array(
            'data_class' => eFaInitTask::class,
            'csrf_token_id' => 'timezone_task'
        ));
        $resolver->setRequired('varData');
    }
}
?>
