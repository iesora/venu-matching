import { useQuery } from "react-query";
import { axiosInstance } from "@/utils/url";
import { Event } from "@/type";
import { AxiosError } from "axios";

const getEventById = async (id: string): Promise<Event> => {
  const response = await axiosInstance.get(`/event/detail/${id}`);
  return response.data;
};

export const useAPIGetEventById = (id: string) => {
  return useQuery<Event, AxiosError>({
    queryKey: ["event", id],
    queryFn: () => getEventById(id),
    enabled: !!id, // idが存在する場合のみクエリを実行
  });
};
