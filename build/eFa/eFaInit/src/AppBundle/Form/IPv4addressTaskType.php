<?php
// src/AppBundle/Form/IPv4addressTaskType.php

namespace AppBundle\Form;

use AppBundle\Entity\IPv4addressTask;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\TextType;

class IPv4addressTaskType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('IPv4address', TextType::class, array(
                'label'           => 'Please enter a valid IPv4 address',
                'required'        => false,
                'trim'            => true,
                'data'         => $options['ipv4address']
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
            'data_class'    => IPv4addressTask::class,
            'csrf_token_id' => 'ipv4address_task'
        ));
        $resolver->setRequired('ipv4address');
    }
}
?>
