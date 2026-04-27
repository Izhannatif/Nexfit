import React, { useContext, useEffect, useState } from 'react'
import AuthContext from '../Context/AuthContext'
import { useNavigate, Link } from 'react-router-dom'
import axios from 'axios'
import { Bar } from 'react-chartjs-2'
import Chart from 'chart.js/auto';
import CanvasJSReact from '@canvasjs/react-charts';
import Sidebar from '../Components/Sidebar'
import { Line } from 'react-chartjs-2';
import 'chart.js/auto';
import DatePicker from '../Components/DatePicker';
import AttendanceChart from '../Components/AttendanceChart';
import MonthlyRevenueChart from '../Components/MonthlyRevenueChart'

const Dashboard = () => {

    var CanvasJS = CanvasJSReact.CanvasJS;
    var CanvasJSChart = CanvasJSReact.CanvasJSChart;

    let { user, logoutUser } = useContext(AuthContext)
    const getCurrentWeekMonday = () => {
        const today = new Date();
        const dayOfWeek = today.getDay();
        const diff = today.getDate() - dayOfWeek + (dayOfWeek === 0 ? -6 : 1);
        return new Date(today.setDate(diff));
    };
    
    const [currentWeek, setCurrentWeek] = useState(getCurrentWeekMonday());
    const[revenueData, setRevenueData] = useState({})
    const [attendanceData, setAttendanceData] = useState({
        Monday: 0,
        Tuesday: 0,
        Wednesday: 0,
        Thursday: 0,
        Friday: 0,
        Saturday: 0,
        Sunday: 0,
    });
    useEffect(() => {
        console.log(user);
        getUserData(user.user_id);
        fetchAttendanceData(currentWeek);
        const fetchRevenueData = async () => {
            try {
              const response = await axios.get('http://192.168.1.13:8001/api/revenue/monthly');
              console.log(response.data);
              setRevenueData(response.data);
            } catch (error) {
              console.error('Error fetching revenue data:', error);
            }
          };
      
          fetchRevenueData();
        // getGymUsers(user.gym);
    }, [currentWeek])

    const [userData, setUserData] = useState([])
    const [gymUsers, setGymUsers] = useState([])
    const [gymTrainers, setGymTrainers] = useState([])
    const [gymEquipments, setGymEquipments] = useState([])
    const [equipmentQuantity, setEquipmentQuantity]=useState([])
    var quantity = 0;

    const navigate = useNavigate()
    const logout = () => {
        const response = logoutUser()
        if (response === 'success') {
            navigate('/login')
        }
    };

    const getUserData = async (id) => {
        let response1 = await axios.get(`http://192.168.1.13:8001/api/admin/${id}/`)
        console.log(response1.data)
        setUserData(response1.data)
        let response2 = await axios.get(`http://192.168.1.13:8001/api/gym-users/${response1.data.gym}/`)
        console.log(response2.data)
        setGymUsers(response2.data)
        let response3 = await axios.get(`http://192.168.1.13:8001/api/gym-trainers/${response1.data.gym}/`)
        console.log(response3.data)
        setGymTrainers(response3.data)
        let response4 = await axios.get(`http://192.168.1.13:8001/api/${response1.data.gym}/all-equipments/`)
        console.log(response4.data)
        console.log(quantity + response4.data.quantity)
        setEquipmentQuantity(quantity + response4.data.quantity);
        // setEquipmentQuantity(response4.data.quantity++)

        setGymEquipments(response4.data)

    }
    const fetchAttendanceData = async (week) => {
        const formattedDate = week.toISOString().split('T')[0];
        try {
            const response = await axios.get(`http://192.168.1.13:8001/api/attendance/weekly/?week=${formattedDate}`);
            setAttendanceData(response.data);
        } catch (error) {
            console.error("Error fetching attendance data:", error);
        }
    };
    return (
        <Sidebar pageName="Dashboard">
            
            <div className='bg-main rounded-xl text-xl font-medium p-5 text-white mb-7'>
                Hello, <span className='font-semibold'>{userData.first_name}</span> 👋
            </div>
            <div className='grid grid-cols-4 gap-10'>
                <div className='dashboard-stats'>
                    <p className='text-md font-semibold'>Total Members</p>
                    <p className='font-bold text-2xl'>{gymUsers.length}</p>
                </div>
                <div className='dashboard-stats'>
                    <p className='text-md font-semibold'>Total Trainers</p>
                    <p className='font-bold text-2xl'>{gymTrainers.length}</p>
                </div>
                <div className='dashboard-stats'>
                    <p className='text-md font-semibold'>Revenue Generated</p>
                    <p className='font-bold text-2xl'>Rs {(revenueData.June)} /-</p>
                </div>
                <div className='dashboard-stats'>
                    <p className='text-md font-semibold'>Total Equipments</p>
                    <p className='font-bold text-2xl'>{gymEquipments.total_quantity}</p>
                </div>
            </div>

            <div className='grid grid-cols-2 gap-10'>
            <div className="bg-main p-5 rounded-xl mt-7">
            <h1 className='text-md font-semibold'>Weekly Gym Attendance</h1>
            <DatePicker
                currentWeek={currentWeek}
                setCurrentWeek={setCurrentWeek}
                onDateChange={fetchAttendanceData}
            />
            <div className='w-full'>
                <AttendanceChart data={attendanceData} />
            </div>
            </div>
            <div className="bg-main p-5 rounded-xl mt-7">
                <MonthlyRevenueChart />
            </div>
        </div>
        </Sidebar>
    )
}

export default Dashboard

