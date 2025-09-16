import { useQuery } from "react-query";
import { axiosInstance } from "@/utils/url";
import { creatorURL } from "@/utils/url/creator";
import { Creator } from "@/type";
import { AxiosError } from "axios";

const getCreators = async (userId?: number) => {
  const response = await axiosInstance.get(creatorURL, { params: { userId } });
  return response.data;
};

export const useAPIGetCreators = (userId?: number) => {
  return useQuery<Creator[], AxiosError>({
    queryKey: ["creators"],
    queryFn: () => getCreators(userId),
  });
};
