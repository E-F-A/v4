<?php
// src/AppBundle/Form/LanguageTaskType.php

namespace AppBundle\Form;

use AppBundle\Entity\eFaInitTask;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;

class LanguageEditTaskType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('Language', ChoiceType::class, array(
                'choices' => array(
                    'Danish' => 'da',
                    'Dutch' => 'nl',
                    'English' => 'en',
                    'French' => 'fr',
                    'German' => 'de',
                    'Italian' => 'it',
                    'Portuguese' => 'pt_PT',
                    'Russian' => 'ru',
                    'Simplified Chinese' => 'zh_CN',
                    'Swedish' => 'sv',
                    'Traditional Chinese' => 'zh_TW',
                    'Turkish' => 'tr',
                    ),
                'preferred_choices' => array($options['locale']),
                'expanded' => false,
                'multiple' => false,
                'attr' => array('onchange' => "window.location.replace('../' + this.value + '/edit')"),
                'choice_translation_domain' => true
                ))
            ->add('Save', SubmitType::class)
        ;
    }
    public function configureOptions(OptionsResolver $resolver)
    {
        $resolver->setDefaults(array(
            'data_class' => eFaInitTask::class,
            'csrf_token_id' => 'language_task'
        ));
        $resolver->setRequired('locale');
    }
}
?>
