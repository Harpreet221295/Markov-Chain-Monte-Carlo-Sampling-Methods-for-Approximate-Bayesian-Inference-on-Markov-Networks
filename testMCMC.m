function [list_M, list_all_samples] = testMCMC(G, F, E, TransName, mix_time, num_samples, sampling_interval, A0, n)

	list_M = [];
	list_all_samples = [];


	for i=1:n,
		 printf("TransName %s\n", TransName{i});
		 printf("Mix time %d \n", mix_time{i});
		 printf("num samples %d\n", num_samples{i});
		 printf("sampling_interval%d\n", sampling_interval{i});
		 printf("A0\n")
		 disp(A0{i});
		 [M, all_samples] = MCMCInference(G{i}, F{i}, E{i}, TransName{i}, mix_time{i}, num_samples{i}, sampling_interval{i}, A0{i});

		 list_M = [list_M M];
		 list_all_samples = [list_all_samples all_samples];
	end;

end

		

