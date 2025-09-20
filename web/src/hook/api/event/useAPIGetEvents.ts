import { useQuery } from "react-query";
import { axiosInstance } from "@/utils/url";
import { Event } from "@/type";
import { AxiosError } from "axios";

const getEvents = async () => {
  const response = await axiosInstance.get("/event/list");
  return response.data;
};

export const useAPIGetEvents = () => {
  return useQuery<Event[], AxiosError>({
    queryKey: ["events"],
    queryFn: getEvents,
  });
};
