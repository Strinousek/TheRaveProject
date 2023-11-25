import React, { useEffect, useState } from "react";
import styled from "styled-components";
import TitleDivider from "./TitleDivider";
import { useFetchStats } from "../hooks/useFetchStats";
import { PlayedTimeInterface } from "../utils/types";

const BoardWrapper = styled.div`
    position: relative;
    padding: 16px;
    width: 80%;
    height: 80%;
    background: linear-gradient(180deg, rgba(0, 0, 0, 0.452) 39%, rgba(211, 81, 0, 0.479) 100%);
    border-radius: 8px;
    display: flex;
    justify-content: center;
    flex-direction: column;
`;

const Header = styled.div`
    position: relative;
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 30%;
    width: 100%;
    & > div {
        display: flex;
        justify-content: space-between;
        align-items: center;
        color: white;
    }
`;

const HeaderTitle = styled.div`
    font-size: 32px;
    text-transform: uppercase;
    font-weight: bold;
    white-space: nowrap;
`;

const HeaderTime = styled.div`
    text-transform: uppercase;
    font-weight: semibold;
    white-space: nowrap;
`;

const Board: React.FC = () => {
    const {loading, data, error} = useFetchStats();
    const [playedTime, setPlayedTime] = useState<PlayedTimeInterface>(data.playedTime);
    const [rewards, setRewards] = useState([]);

    useEffect(() => {
        const intervalId = setInterval(() => {
            const updatedTime = {...playedTime};
            updatedTime.seconds++;
            if(updatedTime.seconds === 60) {
                updatedTime.minutes++;
                updatedTime.seconds = 0;
            }
            if(updatedTime.minutes === 60) {
                updatedTime.hours++;
                updatedTime.minutes = 0;
            }
            if(updatedTime.hours === 24) {
                updatedTime.days++;
                updatedTime.hours = 0;
            }
            setPlayedTime(updatedTime);
        }, 1000);
        return () => clearInterval(intervalId);
    });

    return (<BoardWrapper>
        <Header>
            <HeaderTitle>TRP - Odměny</HeaderTitle>
            <TitleDivider/>
            <HeaderTime>Odehraný čas: 
                {!loading ? 
                    (<>{playedTime.days}d {playedTime.hours}h {playedTime.minutes}m {playedTime.seconds}s)</>) : <>Načítání...</>
                }
            </HeaderTime>
        </Header>
    </BoardWrapper>)
};

export default Board;