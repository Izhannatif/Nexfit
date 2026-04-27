import React, { useEffect, useState } from 'react';
import { Line } from 'react-chartjs-2';
import axios from 'axios';

const MonthlyRevenueChart = () => {
  const [revenueData, setRevenueData] = useState({});

  useEffect(() => {
    const fetchRevenueData = async () => {
      try {
        const response = await axios.get('http://192.168.1.13:8001/api/revenue/monthly');
        setRevenueData(response.data);
      } catch (error) {
        console.error('Error fetching revenue data:', error);
      }
    };

    fetchRevenueData();
  }, []);

  const months = Object.keys(revenueData);
  const revenueValues = Object.values(revenueData);

  const chartData = {
    labels: months,
      legend: {
        display: false
    },
    datasets: [
      {
        label: 'Monthly Revenue',
        data: revenueValues,
        fill: false,
        backgroundColor: '#cddc39',
        borderColor: '#cddc39',
        borderWidth: 2,
      },
    ],
  };

  return (
    <div>
      <h2 className='text-md font-semibold'>Monthly Revenue</h2>
      <Line
        data={chartData}
        
        options={{
          scales: {
            yAxes: [
              {
                ticks: {
                  beginAtZero: true,
                },
              },
            ],
          },
        }}
      />
    </div>
  );
};

export default MonthlyRevenueChart;
