import { useQuery } from "react-query";
import { axiosInstance } from "@/utils/url";
import { venueURL } from "@/utils/url/venue";
import { Venue } from "@/type";
import { AxiosError } from "axios";

const getVenueById = async (id: string): Promise<Venue> => {
  const response = await axiosInstance.get(`${venueURL}/${id}`);
  return response.data;
};

export const useAPIGetVenueById = (id: string) => {
  return useQuery<Venue, AxiosError>({
    queryKey: ["venue", id],
    queryFn: () => getVenueById(id),
    enabled: !!id, // idが存在する場合のみクエリを実行
  });
};
