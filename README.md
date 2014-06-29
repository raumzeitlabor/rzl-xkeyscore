rzl-xkeyscore
=============

Subscribes to MQTT topic # (all topics) and stores all MQTT broker messages in a database.

# Database Table

We use this table structure to store the messages. The following example is based on the MySQL syntax.

    CREATE TABLE `messages` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `topic` text NOT NULL,
      `payload` longblob,
      `qos` tinyint(1) DEFAULT NULL,
      `when` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
      `retain` tinyint(1) NOT NULL DEFAULT '0',
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=241 DEFAULT CHARSET=utf8

# Blacklisting Topics

To protect the privacy of individuals, certain topics can be blacklisted by putting them into the `rzl-xkeyscore.yml`.
