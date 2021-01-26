package Joseph;

import java.util.Scanner;

public class Joseph {
    public static void main(String[] args){
        Scanner scanner=new Scanner(System.in);
        System.out.print("总人数：");
        int totalNum=scanner.nextInt();
        System.out.print("从几号开始报数：");
        int startNum=scanner.nextInt();
        System.out.print("报数的大小:");
        int cycleNum=scanner.nextInt();
        System.out.print(sorting(totalNum,startNum,cycleNum));
        scanner.close();
    }

    public static int sorting(int n,int start,int step){
        int[] all=null;
        //初始化这个队列,将数列按1,2,3……进行编号
        if(all==null){
            all=new int[n];
            for(int i=0;i<n;i++){
                all[i]=i+1;
            }
        }
        //计算出数组的开始数下标，编号比对应的数组下标大1
        int startIndex=start-1;
        while(all[1]!=0){

            for(int i=0;i<n;i++){
                System.out.print(all[i]+"-");
            }
            System.out.println();
            //计算出要删除数组的下标
            int removeIndex=(startIndex+step-1)%n;
            startIndex=removeIndex;
            //将要删除的数字后面的数字往前移动一个位置
            while(removeIndex<n-1){
                all[removeIndex]=all[removeIndex+1];
                removeIndex++;
            }
            //将最后一个位置的数字设置为0
            all[n-1]=0;
            //每次只删除一个
            n--;
        }
        System.out.println();
        return all[0];

    }
}
