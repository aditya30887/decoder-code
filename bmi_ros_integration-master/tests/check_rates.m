
function percent_correct = check_rates(rates, bin, dummyfile, nchan, ncodes, first_ts)


nunits = nchan*ncodes;

fprintf('checking rates\n');
fprintf('first_ts = %f\n', first_ts);
fprintf('size(rates) = %d by %d\n', size(rates, 1), size(rates, 2));
fprintf('nunits = %d\n', nunits);


unit = 1;

has_timestamps = zeros(1, nunits);
max_timestamp = zeros(1, nunits);


timestamps(nunits).timestamps = [];
for ch = 1:nchan
    for co = 1:ncodes  % sorted units only
        [n, timestamps(unit).timestamps] = plx_ts(dummyfile, ch, co);
        has_timestamps(unit) = n > 0;
        if n > 0
            max_timestamp(unit) = max(timestamps(unit).timestamps);
        end
        unit = unit + 1;
    end
end

disp('finding true rates');
maxts = max(max_timestamp);

edges = 0:bin:maxts;
Ntruth = length(edges);
rates_truth = zeros(nunits, Ntruth);
for i = 1:nunits
   rates_truth(i,:) = 1/bin*histc(timestamps(i).timestamps - first_ts, edges);
end


rates_cat = zeros(2*nunits, Ntruth);
rates_cat(nunits+1:end, :) =rates_truth;


first_bin = ceil(first_ts/bin);
N = size(rates,2);

rates_truth = rates_truth(:, 1:N);



figure(99);
subplot(311);
imagesc(rates);

subplot(312);
imagesc(rates_truth);

subplot(313);
imagesc(rates - rates_truth);


percent_correct = 100*mean(vec(rates - rates_truth == 0));




end

