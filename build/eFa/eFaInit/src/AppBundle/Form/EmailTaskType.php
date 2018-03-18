<?php
// src/AppBundle/Form/HostnameTaskType.php

namespace AppBundle\Form;

use AppBundle\Entity\EmailTask;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\TextType;

class EmailTaskType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('Textbox', TextType::class, array(
                'label'           => 'Please enter an email address for important notifications',
                'required'        => false,
                'trim'            => true,
                'data'         => $options['email']
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
            'data_class'    => EmailTask::class,
            'csrf_token_id' => 'email_task'
        ));
        $resolver->setRequired('email');
    }
}
?>
