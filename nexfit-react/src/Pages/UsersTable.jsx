import React, { useContext, useEffect, useState } from 'react'
import AuthContext from '../Context/AuthContext'
import { useNavigate, Link } from 'react-router-dom'
import axios from 'axios'
import Sidebar from '../Components/Sidebar'
import { FaPlus } from "react-icons/fa";
import {
    Card,
    CardHeader,
    Input,
    Typography,
    Button,
    CardBody,
    Chip,
    CardFooter,
    Tabs,
    TabsHeader,
    Tab,
    Avatar,
    IconButton,
    Tooltip,
} from "@material-tailwind/react";
import { FaEdit } from 'react-icons/fa';

const TABS = [
    {
        label: "All",
        value: "all",
    },
    {
        label: "Monitored",
        value: "monitored",
    },
    {
        label: "Unmonitored",
        value: "unmonitored",
    },
];

const TABLE_HEAD = ["ID", "Username", "Name", "Email", "Contact", "Trainer", "Tokens", "Edit"];

const TABLE_ROWS = [

];
const UsersTable = () => {
    let { user } = useContext(AuthContext)

    useEffect(() => {
        console.log(user);
        getUserData(user.user_id);
    }, [])

    const [userData, setUserData] = useState([])
    const [gymUsers, setGymUsers] = useState([])

    const navigate = useNavigate()


    const getUserData = async (id) => {
        let response1 = await axios.get(`http://192.168.1.13:8001/api/admin/${id}/`)
        console.log(response1.data)
        setUserData(response1.data)
        let response2 = await axios.get(`http://192.168.1.13:8001/api/gym-users/${response1.data.gym}/`)
        console.log(response2.data)
        setGymUsers(response2.data)
    }
    return (
        <Sidebar pageName="Members">
        <div className="mb-8 flex items-center justify-between gap-8">
            <div className="flex shrink-0 flex-col gap-2 sm:flex-row">
                <Link to={'/add-user'} className="btn-new"><FaPlus className="mr-2"/> New Member</Link>
            </div>
        </div>
        <div className="bg-main p-3 rounded-xl">
            <table className="w-full table-auto text-left">
                <thead>
                    <tr>
                        {TABLE_HEAD.map((head) => (
                            <th key={head} className="bg-black border-y border-y-gray-900 p-4">
                                {head}
                            </th>
                        ))}
                    </tr>
                </thead>
                <tbody>
                    {gymUsers.map(
                        (user, index) => {
                            const isLast = index === gymUsers.length - 1;
                            const classes = isLast
                                ? "p-4"
                                : "p-4 border-b border-gray-900";

                            return (
                                <tr key={index}>
                                    <td className={classes}>
                                        {user.id}
                                    </td>
                                    <td className={classes}>
                                        {user.username}
                                    </td>
                                    <td className={classes}>
                                        {user.first_name} {user.last_name}
                                    </td>
                                    <td className={classes}>
                                        {user.email}
                                    </td>
                                    <td className={classes}>
                                        {user.contact}
                                    </td>
                                    <td className={classes}>
                                            <Chip
                                                variant="ghost"
                                                size="sm"
                                                value={user.trainerSelected ? "Yes" : "No"}
                                                color={user.trainerSelected ? "green" : "blue-gray"}
                                            />
                                    </td>
                                    {/* <td className={classes}>
                                        <div className="w-max">
                                            <Chip
                                                variant="ghost"
                                                size="sm"
                                                value={user. ? "Active" : "Pending"}
                                                color={user.trainerSelected ? "green" : "blue-gray"}
                                            />
                                        </div>
                                    </td> */}
                                    <td className={classes}>
                                        {user.number_of_tokens}
                                    </td>
                                    <td className={classes}>
                                        <Link to={`/edit-user/${user.id}`} ><FaEdit /></Link>
                                    </td>
                                </tr>
                            );
                        },
                    )}
                </tbody>
            </table>
            </div>
        </Sidebar>
    )
}

export default UsersTable


// import { MagnifyingGlassIcon } from "@heroicons/react/24/outline";
// import { PencilIcon, UserPlusIcon } from "@heroicons/react/24/solid";
