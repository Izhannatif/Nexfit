import React from 'react';
import { Bar } from 'react-chartjs-2';
import 'chart.js/auto';

const AttendanceChart = ({ data }) => {
  const chartData = {
    labels: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
    datasets: [{
      label: 'Attendance per Day',
      data: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map(day => data[day] || 0),
      backgroundColor: '#CDDC39',
      borderColor: '#1F1F1F',
      borderWidth: 0.5,
      borderRadius:15,
      
    }],
  };

  const options = {
    scales: {
      y: {
        beginAtZero: true,
      },
    },
  };

  return <Bar  data={chartData} options={options} className='rounded-lg' />;
};

export default AttendanceChart;
