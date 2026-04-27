import React from 'react';
import { FaArrowCircleLeft, FaArrowCircleRight } from "react-icons/fa";

const DatePicker = ({ currentWeek, setCurrentWeek, onDateChange }) => {
    const handleDateChange = (event) => {
        const selectedDate = new Date(event.target.value);
        setCurrentWeek(selectedDate);
        onDateChange(selectedDate);
    };

    const handleWeekChange = (offset) => {
        const newWeek = new Date(currentWeek);
        newWeek.setDate(currentWeek.getDate() + offset);
        setCurrentWeek(newWeek);
        onDateChange(newWeek);
    };

    return (
        <div className='flex justify-between items-center mt-3'>
            <input
                type="date"
                value={currentWeek.toISOString().split('T')[0]}
                onChange={handleDateChange}
                className='text-white rounded-lg border border-gray-800 bg-black'
            />
            <div>
                <button className='mr-3' onClick={() => handleWeekChange(-7)}>{<FaArrowCircleLeft size={24} color='#cddc39' />}</button>
                <button onClick={() => handleWeekChange(7)}>{<FaArrowCircleRight size={24} color='#cddc39' />}</button>
            </div>
        </div>
    );
};

export default DatePicker;
