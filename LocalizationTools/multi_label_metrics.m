function [Acc,Precision,Recall,F1_score]=multi_label_metrics(true_labels,pred_labels)

T=find(true_labels);
P=find(pred_labels);
num_corr_labels=length(intersect(T,P));
num_union_labels=length(union(T,P));


Acc=num_corr_labels*100/num_union_labels;
Precision=num_corr_labels/length(P);
Recall=num_corr_labels/length(T);
if Precision == 0 && Recall==0
   F1_score=0; 
else
  F1_score = 2*Precision*Recall/(Precision+Recall);  
end
