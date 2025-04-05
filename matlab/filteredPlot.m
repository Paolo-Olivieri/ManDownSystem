function [filtered_data] = filteredPlot(data,time,cutoff_freq,order)
    filtered_data = butterworthFilter(data,time,cutoff_freq,order);

    figure;
    plot(time, data, 'b', 'DisplayName', 'Original Data');
    hold on;
    plot(time, filtered_data, 'r', 'DisplayName', 'Filtered Data');
    xlabel('Timestamp (s)');
    ylabel('Datas');
    legend;
    title('Original and Filtered Datas');
    hold off;
end

