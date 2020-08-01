%CLIQUETREECALIBRATE Performs sum-product or max-product algorithm for 
%clique tree calibration.

%   P = CLIQUETREECALIBRATE(P, isMax) calibrates a given clique tree, P 
%   according to the value of isMax flag. If isMax is 1, it uses max-sum
%   message passing, otherwise uses sum-product. This function 
%   returns the clique tree where the .val for each clique in .cliqueList
%   is set to the final calibrated potentials.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function P = CliqueTreeCalibrate(P, isMax)


% Number of cliques in the tree.
N = length(P.cliqueList);

% Setting up the messages that will be passed.
% MESSAGES(i,j) represents the message going from clique i to clique j. 
MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% We have split the coding part for this function in two chunks with
% specific comments. This will make implementation much easier.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% YOUR CODE HERE
% While there are ready cliques to pass messages between, keep passing
% messages. Use GetNextCliques to find cliques to pass messages between.
% Once you have clique i that is ready to send message to clique
% j, compute the message and put it in MESSAGES(i,j).
% Remember that you only need an upward pass and a downward pass.

if isMax == 1,
	for i=1:N,
		P.cliqueList(i).val = log(P.cliqueList(i).val);
	end;
end;

edges = P.edges;
cliqueList = P.cliqueList;

[idx, jdx] = GetNextCliques(P, MESSAGES);
while(idx~=0 && jdx~=0),

	adj = find(edges(idx, :) == 1);
	sepset_var = intersect(cliqueList(idx).var, cliqueList(jdx).var);


	for i=1:length(adj),
		if adj(i)~=jdx,
			if isMax==0,
				MESSAGES(idx,jdx) = FactorProduct(MESSAGES(idx, jdx), MESSAGES(adj(i), idx));
			else,
				MESSAGES(idx,jdx) = FactorSum(MESSAGES(idx, jdx), MESSAGES(adj(i), idx));
			end;
		end;
	end;

	if isMax==0,
		MESSAGES(idx, jdx) = FactorProduct(MESSAGES(idx, jdx), cliqueList(idx));
		MESSAGES(idx, jdx) = FactorMarginalization(MESSAGES(idx, jdx), setdiff(cliqueList(idx).var, sepset_var));
		MESSAGES(idx, jdx).val = MESSAGES(idx, jdx).val / sum(MESSAGES(idx, jdx).val(:));
	else,
		MESSAGES(idx, jdx) = FactorSum(MESSAGES(idx, jdx), cliqueList(idx));
		MESSAGES(idx, jdx) = FactorMaxMarginalization(MESSAGES(idx, jdx), setdiff(cliqueList(idx).var, sepset_var));
	end;

	[idx, jdx] = GetNextCliques(P, MESSAGES);

end;

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Now the clique tree has been calibrated. 
% Compute the final potentials for the cliques and place them in P.

for i=1:N,
	adj = find(edges(i,:)==1);
	for j=1:length(adj),
		if isMax==0,
			P.cliqueList(i) = FactorProduct(P.cliqueList(i), MESSAGES(adj(j), i));
		else,
			P.cliqueList(i) = FactorSum(P.cliqueList(i), MESSAGES(adj(j), i));
		end;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



return
