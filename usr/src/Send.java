// Java class to send one number from command line to RabbitMQ queue

import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;

public class Send {

    private final static String QUEUE_NAME = "central";

    public static void main(String[] args) throws Exception {
        ConnectionFactory factory = new ConnectionFactory();
        factory.setHost("localhost");
        Connection connection = factory.newConnection();
        Channel channel = connection.createChannel();
//      channel.queueDeclare(QUEUE_NAME, false, false, false, null);

        String Payload = "";
        if (args.length > 0) {
                Payload = args[0].toString();
        } else {
                System.err.println(" [-] Parameter is missing");
                System.exit(1);
        }

        channel.basicPublish("central", QUEUE_NAME, null, Payload.getBytes("UTF-8"));
        System.out.println(" [x] Sent '" + Payload + "' to queue");

        channel.close();
        connection.close();
  }
}
