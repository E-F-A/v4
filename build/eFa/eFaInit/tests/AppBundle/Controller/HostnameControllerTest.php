<?php

namespace Tests\AppBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

class HostnameControllerTest extends WebTestCase
{
    public function testIndex()
    {
        $client = static::createClient();

        $crawler = $client->request('GET', '/en/hostname');

        $this->assertEquals(200, $client->getResponse()->getStatusCode());
        $this->assertContains('Hostname', $crawler->filter('#container h1')->text());
    }
}
