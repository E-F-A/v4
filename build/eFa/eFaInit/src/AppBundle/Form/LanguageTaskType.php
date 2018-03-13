<?php
// src/AppBundle/Form/LanguageTaskType.php

namespace AppBundle\Form;

use AppBundle\Entity\LanguageTask;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;

class LanguageTaskType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('Language', ChoiceType::class, array(
                'choices' => array(
                    'Chinese' => 'zh_CN',
                    'Danish' => 'da',
                    'Dutch' => 'nl',
                    'English' => 'en',
                    'French' => 'fr',
                    'German' => 'de',
                    'Portuguese' => 'pt_PT',
                    'Turkish' => 'tr'
                    ),
                'preferred_choices' => array($options['locale']),
                'expanded' => false,
                'multiple' => false,
                'attr' => array('onchange' => 'window.location.replace(this.value)'),
                'choice_translation_domain' => true
                ))
            ->add('Next', SubmitType::class)
        ;
    }
    public function configureOptions(OptionsResolver $resolver)
    {
        $resolver->setDefaults(array(
            'data_class' => LanguageTask::class,
            'csrf_token_id' => 'language_task'
        ));
        $resolver->setRequired('locale');
    }
}
?>
