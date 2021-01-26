package Joseph;

import java.util.Scanner;

class Node{
    int data;
    Node next;
    public Node(){}
    public Node(int data){this.data = data;}

}
public class josephus {

        public static void count(int n,int k) {
            //数到3出局，中间间隔两个人
            //头结点不存储数据
            Node head = new Node();
            Node cur = head;
            //循环构造这个链表
            for (int i = 1; i <= n; i++) {
                Node node = new Node(i);
                cur.next = node;
                cur = node;
            }
            //链表有数据的部分首尾相连形成一个环。
            cur.next = head.next;
            //统计开始的时候，刨去头结点，然后从第一个有数据的结点开始报数
            Node p = head.next;
            //如果报数从1开始便单独考虑，因找不到1的前驱结点
            if(k==1){
                for(int i=1;i<=n-1;i++){
                    System.out.print(p.data+"->");
                    p=p.next;
                }
                System.out.print(("(left:" + n + ")"));
            }
            //循环退出的条件是最后只剩一个结点，也就是这个结点的下一个结点是它本身
            else{
                while (p.next != p) {
                //正常报数的遍历逻辑
                for (int i = 1; i < k - 1; i++) {
                    p = p.next;
                }
                //当数到3的时候，出局
                System.out.print(p.next.data + "->");
                p.next = p.next.next;
                p = p.next;
                }
                //最后剩下的一个结点
                System.out.println("(left:" + p.data + ")");
            }
        }

        public static void main(String[] args) {
            Scanner scanner = new Scanner(System.in);
            System.out.print("总人数：");
            int totalNum = scanner.nextInt();
            System.out.print("报数的大小：");
            int countNum = scanner.nextInt();
            count(totalNum,countNum);
        }

}

