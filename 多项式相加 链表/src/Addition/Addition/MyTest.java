package Addition.Addition;
import Addition.Addition.MyLink.Node;

public class MyTest {
    public static void main(String[] args) {
        MyLink myLink = new MyLink();
        System.out.println("请依次输入第一个多项式的系数和指数");
        Node nodea = myLink.createLink();
        System.out.println("请依次输入第二个多项式的系数和指数");
        Node nodeb = myLink.createLink();
        System.out.println("输入的第一个多项式是: ");
        myLink.printLink(nodea.next);
        System.out.println("输入的第二个多项式是: ");
        myLink.printLink(nodeb.next);
        Node nodec = myLink.addLink(nodea, nodeb);
        System.out.println("两个多项式的和为: ");
        myLink.printLink(nodec.next);
    }
}